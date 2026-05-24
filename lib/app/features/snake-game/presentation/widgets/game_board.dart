import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/confirm_dialog.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/inline_banner_ad.dart';

/// Dirección de un segmento, de [from] a [to], tolerando el wrap del tablero
/// (cuando un segmento aparece en el borde opuesto).
Direction _segDir(Offset from, Offset to) {
  var dx = to.dx - from.dx;
  var dy = to.dy - from.dy;
  if (dx > 1) {
    dx = -1;
  } else if (dx < -1) {
    dx = 1;
  }
  if (dy > 1) {
    dy = -1;
  } else if (dy < -1) {
    dy = 1;
  }
  if (dx > 0) {
    return Direction.right;
  }
  if (dx < 0) {
    return Direction.left;
  }
  if (dy > 0) {
    return Direction.down;
  }
  return Direction.up;
}

/// Cuartos de giro asumiendo que el sprite apunta a la derecha por defecto.
int _quarterTurns(Direction d) => switch (d) {
  Direction.right => 0,
  Direction.down => 1,
  Direction.left => 2,
  Direction.up => 3,
};

/// Sprite de cabeza según la dirección (hay uno por cada lado).
String _headAsset(Direction d) => switch (d) {
  Direction.up => 'assets/icons/games/snake/snake_head_up.svg',
  Direction.down => 'assets/icons/games/snake/snake_head_down.svg',
  Direction.left => 'assets/icons/games/snake/snake_head_left.svg',
  Direction.right => 'assets/icons/games/snake/snake_head_right.svg',
};

/// La cola apunta a la IZQUIERDA por defecto (la punta a la izquierda, la unión
/// con el cuerpo a la derecha), al revés que el resto: por eso va +2 cuartos.
int _tailQuarterTurns(Direction d) => (_quarterTurns(d) + 2) % 4;

/// Grosor (alto relativo a la celda) del cuerpo y la cola: más finos que la
/// cabeza para que la serpiente no se vea tan "gorda".
const double _snakeSegThickness = 0.7;

/// Sprite de un segmento (cuerpo/cola) rotado y adelgazado en su grosor.
Widget _thinSegment(String asset, int quarterTurns) {
  return RotatedBox(
    quarterTurns: quarterTurns,
    child: FractionallySizedBox(
      widthFactor: 1,
      heightFactor: _snakeSegThickness,
      child: SvgPicture.asset(asset, fit: BoxFit.fill),
    ),
  );
}

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends ConsumerState<GameBoard> {
  /// Ofrece duplicar los puntos de la partida a cambio de ver un rewarded
  /// interstitial. Muestra primero una pantalla de intro (requisito de AdMob).
  void _offerDoublePoints() {
    final score = ref.read(snakeGameProvider).score;

    ConfirmDialog.show(
      title: '¿DUPLICAR PUNTOS?',
      message:
          'Mira un anuncio completo y duplica los $score puntos de tu partida.',
      icon: Icons.play_arrow_rounded,
      accentColor: AppColors.emerald,
      confirmText: 'VER ANUNCIO',
      cancelText: 'AHORA NO',
      onConfirm: () async {
        final shown = await AdsService.instance.showRewardedInterstitial(
          // El servidor duplica la exp de la sesión (idempotente); el monto
          // de AdMob se ignora.
          onReward: (_) async {
            if (!mounted) return;
            final bonus = await ref
                .read(snakeGameProvider.notifier)
                .doubleReward();
            if (bonus > 0) {
              SnackbarService.show(
                '¡Ganaste $bonus puntos extra!',
                type: SnackbarType.success,
              );
            }
          },
        );
        if (!shown) {
          SnackbarService.show(
            'No hay anuncios disponibles por ahora',
            type: SnackbarType.error,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(snakeGameProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula el tamaño de celda basado en el espacio disponible
        final cellWidth = constraints.maxWidth / gameState.gridWidth;
        final cellHeight = constraints.maxHeight / gameState.gridHeight;

        return Stack(
          children: [
            // Grid background with subtle pattern
            Container(
              decoration: BoxDecoration(color: AppColors.purple),
              child: Column(
                children: List.generate(gameState.gridHeight, (rowIndex) {
                  return Expanded(
                    child: Row(
                      children: List.generate(gameState.gridWidth, (colIndex) {
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.neonPurple.withValues(
                                  alpha: 0.3,
                                ),
                                width: 0.5,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),

            // Paredes del nivel: bloques sólidos que matan al chocar.
            ...gameState.walls.map((wall) {
              return Positioned(
                left: wall.dx * cellWidth,
                top: wall.dy * cellHeight,
                width: cellWidth,
                height: cellHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.selector,
                    borderRadius: BorderRadius.circular(cellWidth * 0.15),
                    border: Border.all(
                      color: AppColors.neonPurple.withValues(alpha: 0.7),
                      width: 0.5,
                    ),
                  ),
                ),
              );
            }),

            // Food - more vibrant and with shadow
            Positioned(
              left: gameState.food.dx * cellWidth,
              top: gameState.food.dy * cellHeight,
              width: cellWidth,
              height: cellHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neonPurple,
                  borderRadius: BorderRadius.circular(cellWidth / 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPurple.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                  gradient: RadialGradient(
                    colors: [AppColors.purple, AppColors.neonPurple],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.circle,
                    size: cellWidth * 0.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            if (gameState.extraFood != null)
              // Food - more vibrant and with shadow
              Positioned(
                left: gameState.extraFood!.dx * cellWidth,
                top: gameState.extraFood!.dy * cellHeight,
                width: cellWidth,
                height: cellHeight,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/apple.svg',
                    width: cellWidth,
                  ),
                ),
              ),

            // Snake - sprites de cabeza/cuerpo/cola, rotados según su dirección.
            ...gameState.snake.asMap().entries.map((entry) {
              final index = entry.key;
              final segment = entry.value;
              final snake = gameState.snake;
              final last = snake.length - 1;

              final Widget child;
              if (index == 0) {
                // La cabeza usa un sprite por dirección (sin rotar).
                final dir = snake.length > 1
                    ? _segDir(snake[1], snake[0])
                    : gameState.direction;
                child = SvgPicture.asset(_headAsset(dir), fit: BoxFit.fill);
              } else if (index == last) {
                // La cola apunta hacia afuera (del cuerpo hacia la punta).
                final dir = _segDir(snake[last - 1], snake[last]);
                child = _thinSegment(
                  'assets/icons/games/snake/snake_tail.svg',
                  _tailQuarterTurns(dir),
                );
              } else {
                final dir = _segDir(snake[index + 1], snake[index]);
                child = _thinSegment(
                  'assets/icons/games/snake/snake_body.svg',
                  _quarterTurns(dir),
                );
              }

              return Positioned(
                left: segment.dx * cellWidth,
                top: segment.dy * cellHeight,
                width: cellWidth,
                height: cellHeight,
                child: child,
              );
            }),

            // Game Over overlay - more polished
            if (gameState.hasLost || gameState.isPaused)
              Container(
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.5),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              // Texto con borde
                              Text(
                                gameState.isPaused ? 'Pausa' : 'Perdió',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pixel',
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 4
                                    ..color = AppColors.neonPurple,
                                ),
                              ),
                              // Texto de relleno
                              Text(
                                gameState.isPaused ? 'Pausa' : 'Perdiste',
                                style: TextStyle(
                                  color: AppColors.purple,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pixel',
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${gameState.score} puntos',
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Recompensas otorgadas por el servidor al cerrar la
                          // partida (exp/coins/récord). Solo al perder.
                          if (gameState.hasLost) _GameResult(state: gameState),

                          // Oferta de duplicar puntos (solo al perder, con
                          // score > 0 y si hay un anuncio recompensado listo).
                          // Solo tras confirmar el cierre en el servidor
                          // (result != null): así la sesión ya está finalizada
                          // y se puede duplicar.
                          if (gameState.hasLost &&
                              gameState.score > 0 &&
                              gameState.result != null &&
                              AdsService
                                  .instance
                                  .isRewardedInterstitialReady) ...[
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _offerDoublePoints,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.emerald,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.emerald.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'DUPLICA TUS PUNTOS',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Botón de salir (vuelve al selector de niveles),
                          // visible en pausa y al perder.
                          const SizedBox(height: 20),
                          CustomTextButton(
                            width: 150,
                            height: 44,
                            radius: 12,
                            label: 'SALIR',
                            baseColor: AppColors.backgroundDark,
                            onPressed: () => confirmGameExit(
                              isLost: gameState.hasLost,
                              isPaused: gameState.isPaused,
                              togglePause: ref
                                  .read(snakeGameProvider.notifier)
                                  .togglePause,
                              onLeave: () {
                                ref.read(snakeGameProvider.notifier).abandon();
                                AppRoutes.go(AppRoutes.levelSnakeGame);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Banner inferior – se colapsa solo si no carga.
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(top: false, child: InlineBannerAd()),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Recompensas que el servidor otorgó al cerrar la partida: mientras se envía
/// muestra un loader; al volver, los chips de exp/coins y la insignia de récord.
class _GameResult extends StatelessWidget {
  final SnakeGameState state;

  const _GameResult({required this.state});

  @override
  Widget build(BuildContext context) {
    final result = state.result;

    if (state.isSubmitting || result == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.neonPurple),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Guardando resultado...',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result.levelCleared)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                result.unlockedNext
                    ? '¡NIVEL SUPERADO! +1 DESBLOQUEADO'
                    : '¡NIVEL SUPERADO!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.emerald,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                ),
              ),
            ),
          if (result.isHighScore)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '¡NUEVO RÉCORD!',
                style: TextStyle(
                  color: AppColors.emerald,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResultChip(
                label: '+${result.expGained} EXP',
                color: AppColors.purple,
              ),
              const SizedBox(width: 10),
              _ResultChip(
                label: '+${result.coinsGained} 🪙',
                color: AppColors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ResultChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
