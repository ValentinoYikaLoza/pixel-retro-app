import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/providers/tetris_game_provider.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/widgets/tetris_board.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/widgets/tetris_controls.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/widgets/tetris_starting_loader.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/confirm_dialog.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';

class TetrisGameScreen extends ConsumerStatefulWidget {
  final int level;

  const TetrisGameScreen({super.key, this.level = 1});

  @override
  ConsumerState<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

class _TetrisGameScreenState extends ConsumerState<TetrisGameScreen> {
  @override
  void initState() {
    super.initState();
    setScreenConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tetrisGameProvider.notifier).startGame(level: widget.level);
    });
    AdsService.instance.preloadRewardedInterstitial();
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.neonPurple);
    OrientationService.setPortrait();
    OrientationService.setImmersiveMode();
  }

  void _exit() {
    // Confirma antes de abandonar (avisa que se pierde vida y progreso).
    final st = ref.read(tetrisGameProvider);
    final notifier = ref.read(tetrisGameProvider.notifier);
    confirmGameExit(
      isLost: st.hasLost,
      isPaused: st.isPaused,
      togglePause: notifier.togglePause,
      onLeave: () {
        notifier.abandon();
        AppRoutes.go(AppRoutes.levelTetrisGame);
      },
    );
  }

  /// Overlay que se dibuja dentro del tablero: game over o pausa.
  Widget? _boardOverlay(TetrisGameState state) {
    if (state.hasLost) return _GameOver(state: state, onExit: _exit);
    if (state.isPaused) {
      return _PauseOverlay(
        onResume: () => ref.read(tetrisGameProvider.notifier).togglePause(),
        onExit: _exit,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tetrisGameProvider);
    final lives = ref.watch(userProvider).lives;

    ref.listen(tetrisGameProvider.select((s) => s.startFailed), (_, failed) {
      if (failed == true) {
        SnackbarService.show(
          state.startError ?? 'No se pudo iniciar la partida',
          type: SnackbarType.error,
        );
        AppRoutes.go(AppRoutes.shop);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: setScreenConfig,
          child: SafeArea(
            child: state.isStarting
                ? const TetrisStartingLoader()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(
                      children: [
                        _TopBar(state: state, lives: lives),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: TetrisBoard(
                              state: state,
                              overlay: _boardOverlay(state),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const TetrisControls(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Barra superior (vertical/portrait): hold, siguientes piezas, vidas y stats.
class _TopBar extends StatelessWidget {
  final TetrisGameState state;
  final int lives;

  const _TopBar({required this.state, required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label('HOLD'),
            const SizedBox(height: 4),
            PiecePreview(type: state.holdType, size: 40),
          ],
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label('NEXT'),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final t in state.nextQueue.take(3))
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: PiecePreview(type: t, size: 34),
                  ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Lives(lives),
                const SizedBox(width: 10),
                _StrokedText(
                  state.level == 0 ? 'INFINITO' : 'NIVEL ${state.level}',
                  fontSize: 18,
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Objetivo en LÍNEAS (en infinito no hay meta: solo el conteo).
            Text(
              state.level == 0
                  ? '${state.lines} líneas'
                  : '${state.lines} / ${state.targetScore} líneas',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${state.score} pts',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Indicador compacto de vidas (corazón + número), al estilo del app bar.
class _Lives extends StatelessWidget {
  final int lives;

  const _Lives(this.lives);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/icons/heart.svg', height: 20, width: 20),
        const SizedBox(width: 4),
        Text(
          '$lives',
          style: const TextStyle(
            color: AppColors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.white.withValues(alpha: 0.6),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    );
  }
}

/// Panel de fin de partida con recompensas + oferta de duplicar puntos.
class _GameOver extends ConsumerWidget {
  final TetrisGameState state;
  final VoidCallback onExit;

  const _GameOver({required this.state, required this.onExit});

  void _offerDouble(BuildContext context, WidgetRef ref) {
    ConfirmDialog.show(
      title: '¿DUPLICAR PUNTOS?',
      message: 'Mira un anuncio completo y duplica los ${state.score} puntos.',
      icon: Icons.play_arrow_rounded,
      accentColor: AppColors.emerald,
      confirmText: 'VER ANUNCIO',
      cancelText: 'AHORA NO',
      onConfirm: () async {
        final shown = await AdsService.instance.showRewardedInterstitial(
          onReward: (_) async {
            final bonus = await ref
                .read(tetrisGameProvider.notifier)
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
  Widget build(BuildContext context, WidgetRef ref) {
    final result = state.result;

    return Container(
      color: AppColors.backgroundDark.withValues(alpha: 0.9),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StrokedText(
              result?.levelCleared == true ? '¡SUPERADO!' : 'Perdiste',
              fontSize: 20,
            ),
            const SizedBox(height: 6),
            Text(
              '${state.score} pts · ${state.lines} líneas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.level == 0 && result != null) ...[
              const SizedBox(height: 4),
              Text(
                result.isHighScore
                    ? '¡NUEVO RÉCORD!'
                    : 'Récord: ${result.highScore}',
                style: const TextStyle(
                  color: AppColors.emerald,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (state.isSubmitting || result == null)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.neonPurple),
                ),
              )
            else ...[
              _Chip('+${result.expGained} EXP', AppColors.purple),
              const SizedBox(height: 6),
              _Chip('+${result.coinsGained} 🪙', AppColors.orange),
              if (result.unlockedNext)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Nivel +1 desbloqueado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.emerald,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pixel',
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 14),
            CustomTextButton(
              width: 160,
              height: 42,
              radius: 12,
              label: 'REINTENTAR',
              onPressed: () =>
                  ref.read(tetrisGameProvider.notifier).resetGame(),
            ),
            const SizedBox(height: 8),
            CustomTextButton(
              width: 160,
              height: 40,
              radius: 12,
              label: 'SALIR',
              baseColor: AppColors.backgroundDark,
              onPressed: onExit,
            ),
            if (state.score > 0 &&
                result != null &&
                AdsService.instance.isRewardedInterstitialReady) ...[
              const SizedBox(height: 8),
              CustomTextButton(
                width: 160,
                height: 40,
                radius: 12,
                label: 'x2 PUNTOS',
                flashColor: AppColors.emerald,
                onPressed: () => _offerDouble(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Overlay de pausa dentro del tablero (estilo Snake): reanudar o salir.
class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onExit;

  const _PauseOverlay({required this.onResume, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark.withValues(alpha: 0.9),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _StrokedText('PAUSA', fontSize: 24),
          const SizedBox(height: 16),
          CustomTextButton(
            width: 160,
            height: 42,
            radius: 12,
            label: 'CONTINUAR',
            onPressed: onResume,
          ),
          const SizedBox(height: 8),
          CustomTextButton(
            width: 160,
            height: 40,
            radius: 12,
            label: 'SALIR',
            baseColor: AppColors.backgroundDark,
            onPressed: onExit,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip(this.label, this.color);

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

class _StrokedText extends StatelessWidget {
  final String text;
  final double fontSize;

  const _StrokedText(this.text, {this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pixel',
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = AppColors.neonPurple,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: AppColors.purple,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pixel',
          ),
        ),
      ],
    );
  }
}
