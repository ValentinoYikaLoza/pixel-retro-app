import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_defs.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_sprites.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/providers/invaders_game_provider.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/widgets/invaders_board.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/widgets/invaders_starting_loader.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/confirm_dialog.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';

class InvadersGameScreen extends ConsumerStatefulWidget {
  final int level;

  const InvadersGameScreen({super.key, this.level = 1});

  @override
  ConsumerState<InvadersGameScreen> createState() => _InvadersGameScreenState();
}

class _InvadersGameScreenState extends ConsumerState<InvadersGameScreen> {
  InvadersSprites? _sprites;

  @override
  void initState() {
    super.initState();
    setScreenConfig();
    // Rasteriza los sprites (SVG → imágenes) en paralelo al arranque del juego.
    InvadersSprites.load().then((s) {
      if (mounted) setState(() => _sprites = s);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(invadersGameProvider.notifier).startGame(level: widget.level);
    });
    AdsService.instance.preloadRewardedInterstitial();
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.neonPurple);
    OrientationService.setPortrait();
    OrientationService.setImmersiveMode();
  }

  void _exit() {
    final st = ref.read(invadersGameProvider);
    final notifier = ref.read(invadersGameProvider.notifier);
    confirmGameExit(
      isLost: st.hasLost,
      isPaused: st.isPaused,
      togglePause: notifier.togglePause,
      onLeave: () {
        notifier.abandon();
        AppRoutes.go(AppRoutes.levelInvadersGame);
      },
    );
  }

  Widget? _boardOverlay(InvadersGameState state) {
    if (state.hasLost) return _GameOver(state: state, onExit: _exit);
    if (state.isPaused) {
      return _PauseOverlay(
        onResume: () => ref.read(invadersGameProvider.notifier).togglePause(),
        onExit: _exit,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invadersGameProvider);

    ref.listen(invadersGameProvider.select((s) => s.startFailed), (_, failed) {
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
          behavior: HitTestBehavior.deferToChild,
          onTap: setScreenConfig,
          child: SafeArea(
            child: (state.isStarting || _sprites == null)
                ? const InvadersStartingLoader()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      children: [
                        _TopBar(
                          state: state,
                          onPause: () => ref
                              .read(invadersGameProvider.notifier)
                              .togglePause(),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: InvadersBoard(
                              state: state,
                              sprites: _sprites!,
                              onMove: (f) => ref
                                  .read(invadersGameProvider.notifier)
                                  .moveShipTo(f),
                              overlay: _boardOverlay(state),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Desliza para mover · dispara solo',
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

/// Barra superior: nivel/oleada, vidas de la nave, puntaje/meta, combo y mejoras.
class _TopBar extends StatelessWidget {
  final InvadersGameState state;
  final VoidCallback onPause;

  const _TopBar({required this.state, required this.onPause});

  @override
  Widget build(BuildContext context) {
    final mult = (1 + state.combo * 0.1).clamp(1.0, 3.0);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StrokedText('NIVEL ${state.level}', fontSize: 18),
                Text(
                  'Oleada ${state.wave}',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Vidas de la nave.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                state.shipLives.clamp(0, kMaxShipLives),
                (_) => const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    color: AppColors.neonPurple,
                    size: 16,
                  ),
                ),
              ),
            ),
            // Botón de pausa (oculto al pausar/perder; el overlay toma el control).
            if (!state.isPaused && !state.hasLost)
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
                      border: Border.all(
                        color: AppColors.neonPurple,
                        width: 1.5,
                      ),
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
            const SizedBox(width: 8),
            Text(
              'meta ${state.targetScore}',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            const Spacer(),
            if (state.combo > 1)
              _Badge('x${mult.toStringAsFixed(1)}', AppColors.yellow),
            if (state.rapidActive) _Badge('R', AppColors.orange),
            if (state.tripleActive) _Badge('T', AppColors.yellow),
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
  final InvadersGameState state;
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
                .read(invadersGameProvider.notifier)
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
              fontSize: 22,
            ),
            const SizedBox(height: 6),
            Text(
              '${state.score} pts · ${state.kills} bajas',
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
                  ref.read(invadersGameProvider.notifier).resetGame(),
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
