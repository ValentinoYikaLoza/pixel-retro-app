import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/logic/pacman_maze.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/providers/pacman_game_provider.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/widgets/pacman_board.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/widgets/pacman_starting_loader.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/confirm_dialog.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';

class PacmanGameScreen extends ConsumerStatefulWidget {
  final int level;

  const PacmanGameScreen({super.key, this.level = 1});

  @override
  ConsumerState<PacmanGameScreen> createState() => _PacmanGameScreenState();
}

class _PacmanGameScreenState extends ConsumerState<PacmanGameScreen> {
  /// Origen del arrastre actual y umbral mínimo para registrar un swipe. El
  /// gesto se captura en toda la pantalla (no solo sobre el tablero).
  Offset? _dragStart;
  static const double _swipeThreshold = 14;

  void _onPanUpdate(Offset current) {
    final start = _dragStart;
    if (start == null) {
      _dragStart = current;
      return;
    }
    final dx = current.dx - start.dx;
    final dy = current.dy - start.dy;
    if (dx.abs() < _swipeThreshold && dy.abs() < _swipeThreshold) return;
    final dir = dx.abs() > dy.abs()
        ? (dx > 0 ? PacDir.right : PacDir.left)
        : (dy > 0 ? PacDir.down : PacDir.up);
    ref.read(pacmanGameProvider.notifier).setWantDir(dir);
    _dragStart = current; // permite encadenar flicks dentro del mismo arrastre
  }

  @override
  void initState() {
    super.initState();
    setScreenConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pacmanGameProvider.notifier).startGame(level: widget.level);
    });
    AdsService.instance.preloadRewardedInterstitial();
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.neonPurple);
    OrientationService.setPortrait();
    OrientationService.setImmersiveMode();
  }

  void _exit() {
    final st = ref.read(pacmanGameProvider);
    final notifier = ref.read(pacmanGameProvider.notifier);
    confirmGameExit(
      isLost: st.hasLost || st.hasWon,
      isPaused: st.isPaused,
      togglePause: notifier.togglePause,
      onLeave: () {
        notifier.abandon();
        AppRoutes.go(AppRoutes.levelPacmanGame);
      },
    );
  }

  Widget? _boardOverlay(PacmanGameState state) {
    if (state.hasWon || state.hasLost) {
      return _GameOver(state: state, onExit: _exit);
    }
    if (state.isPaused) {
      return _PauseOverlay(
        onResume: () => ref.read(pacmanGameProvider.notifier).togglePause(),
        onExit: _exit,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pacmanGameProvider);

    ref.listen(pacmanGameProvider.select((s) => s.startFailed), (_, failed) {
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
          // Opaco para capturar el swipe en toda la pantalla, también fuera del
          // tablero (antes solo respondía sobre él).
          behavior: HitTestBehavior.opaque,
          onTap: setScreenConfig,
          onPanDown: (d) => _dragStart = d.localPosition,
          onPanStart: (d) => _dragStart = d.localPosition,
          onPanUpdate: (d) => _onPanUpdate(d.localPosition),
          onPanEnd: (_) => _dragStart = null,
          onPanCancel: () => _dragStart = null,
          child: SafeArea(
            child: state.isStarting
                ? const PacmanStartingLoader()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      children: [
                        _TopBar(
                          state: state,
                          onPause: () =>
                              ref.read(pacmanGameProvider.notifier).togglePause(),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: PacmanBoard(
                              state: state,
                              overlay: _boardOverlay(state),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Desliza para girar · cómete todos los puntos',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Barra superior: nivel, vidas, puntaje/meta (pellets) y botón de pausa.
class _TopBar extends StatelessWidget {
  final PacmanGameState state;
  final VoidCallback onPause;

  const _TopBar({required this.state, required this.onPause});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _StrokedText('NIVEL ${state.level}', fontSize: 18),
            const Spacer(),
            // Vidas.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                state.lives.clamp(0, 5),
                (_) => const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Icon(Icons.pie_chart, color: AppColors.yellow, size: 16),
                ),
              ),
            ),
            if (!state.isPaused && !state.hasWon && !state.hasLost)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: onPause,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.neonPurple, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${state.score} pts',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'puntos ${state.pelletsEaten}/${state.targetScore}',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            const Spacer(),
            // Combo (cadena de pellets) y power-ups activos.
            if (state.chainMult > 1)
              _Badge('x${state.chainMult}', AppColors.yellow),
            if (state.speedActive) _Badge('V', AppColors.orange),
            if (state.freezeActive) _Badge('F', const Color(0xFF49E0E0)),
            if (state.doubleActive) _Badge('x2', AppColors.emerald),
            if (state.magnetActive) _Badge('M', const Color(0xFFB57BFF)),
            if (state.shieldActive) _Badge('S', const Color(0xFF4FC3F7)),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Fin de partida (dentro del tablero): resultado + reintentar/salir/x2.
class _GameOver extends ConsumerWidget {
  final PacmanGameState state;
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
            final bonus =
                await ref.read(pacmanGameProvider.notifier).doubleReward();
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
            _StrokedText(state.hasWon ? '¡SUPERADO!' : 'Perdiste', fontSize: 22),
            const SizedBox(height: 6),
            Text(
              '${state.score} pts · ${state.pelletsEaten} puntos',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  ref.read(pacmanGameProvider.notifier).resetGame(),
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
