import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/providers/tetris_game_provider.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/widgets/tetris_board.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/widgets/tetris_controls.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/dialog_service.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_icon_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/rewarded_ad_offer_dialog.dart';

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
    OrientationService.setLandscape();
    OrientationService.setImmersiveMode();
  }

  void _exit() {
    ref.read(tetrisGameProvider.notifier).abandon();
    AppRoutes.go(AppRoutes.levelTetrisGame);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tetrisGameProvider);

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
            child: Stack(
              children: [
                if (state.isStarting)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.neonPurple,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _StatsPanel(state: state)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TetrisBoard(state: state),
                        ),
                        const Expanded(flex: 3, child: TetrisControls()),
                      ],
                    ),
                  ),
                // Botón de salir (vuelve al selector), bajo el overlay de fin.
                Positioned(
                  top: 4,
                  left: 4,
                  child: CustomIconButton(
                    onPressed: _exit,
                    width: 44,
                    height: 44,
                    imagePath: 'assets/icons/back.svg',
                  ),
                ),
                if (state.hasLost) _GameOver(state: state, onExit: _exit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel izquierdo: nivel, hold, siguientes piezas y estadísticas.
class _StatsPanel extends StatelessWidget {
  final TetrisGameState state;

  const _StatsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StrokedText('NIVEL ${state.level}', fontSize: 20),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const _Label('HOLD'),
                const SizedBox(height: 4),
                PiecePreview(type: state.holdType, size: 44),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                const _Label('NEXT'),
                const SizedBox(height: 4),
                for (final t in state.nextQueue.take(3)) ...[
                  PiecePreview(type: t, size: 40),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Stat('Puntos', '${state.score}'),
        _Stat('Líneas', '${state.lines}'),
        _Stat('Meta', '${state.targetScore}'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          _Label(label),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
    DialogService.show(
      RewardedAdOfferDialog(
        title: '¿Duplicar tus puntos?',
        message:
            'Mira un anuncio completo y duplica los ${state.score} puntos.',
        onAccept: () async {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = state.result;

    return Container(
      color: AppColors.backgroundDark.withValues(alpha: 0.88),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StrokedText(
              result?.levelCleared == true ? '¡NIVEL SUPERADO!' : 'GAME OVER',
              fontSize: 30,
            ),
            const SizedBox(height: 6),
            Text(
              '${state.score} pts · ${state.lines} líneas',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            if (state.isSubmitting || result == null)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.neonPurple),
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Chip('+${result.expGained} EXP', AppColors.purple),
                  const SizedBox(width: 10),
                  _Chip('+${result.coinsGained} 🪙', AppColors.orange),
                ],
              ),
              if (result.unlockedNext)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Nivel +1 desbloqueado',
                    style: TextStyle(
                      color: AppColors.emerald,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pixel',
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextButton(
                  width: 130,
                  height: 44,
                  radius: 12,
                  label: 'SALIR',
                  baseColor: AppColors.backgroundDark,
                  onPressed: onExit,
                ),
                const SizedBox(width: 14),
                CustomTextButton(
                  width: 130,
                  height: 44,
                  radius: 12,
                  label: 'REINTENTAR',
                  onPressed: () =>
                      ref.read(tetrisGameProvider.notifier).resetGame(),
                ),
              ],
            ),
            if (state.score > 0 &&
                result != null &&
                AdsService.instance.isRewardedInterstitialReady) ...[
              const SizedBox(height: 12),
              CustomTextButton(
                width: 220,
                height: 42,
                radius: 12,
                label: 'DUPLICAR PUNTOS',
                flashColor: AppColors.orange,
                onPressed: () => _offerDouble(context, ref),
              ),
            ],
          ],
        ),
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
