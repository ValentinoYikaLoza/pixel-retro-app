import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/dialog_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_icon_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/inline_banner_ad.dart';
import 'package:pixel_retro_app/app/shared/widgets/rewarded_ad_offer_dialog.dart';

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends ConsumerState<GameBoard> {
  /// Ofrece vidas extra a cambio de ver un rewarded interstitial.
  /// Muestra primero una pantalla de intro (requisito de AdMob).
  void _offerExtraLives() {
    DialogService.show(
      RewardedAdOfferDialog(
        title: '¿Vidas extra?',
        message: 'Mira un anuncio completo y suma vidas a tu cuenta.',
        onAccept: () async {
          final shown = await AdsService.instance.showRewardedInterstitial(
            onReward: (amount) async {
              if (!mounted) return;
              await ref.read(userProvider.notifier).updateLives(amount.toInt());
              SnackbarService.show(
                '¡Ganaste ${amount.toInt()} vidas!',
                type: SnackbarType.success,
              );
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

            // Snake - with gradient and better head differentiation
            ...gameState.snake.asMap().entries.map((entry) {
              final index = entry.key;
              final segment = entry.value;
              final isHead = index == 0;
              return Positioned(
                left: segment.dx * cellWidth,
                top: segment.dy * cellHeight,
                width: cellWidth,
                height: cellHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: isHead ? Colors.blue.shade900 : Colors.blue.shade700,
                    borderRadius: isHead
                        ? BorderRadius.circular(cellWidth / 3)
                        : BorderRadius.circular(cellWidth / 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isHead
                          ? [AppColors.orange, AppColors.red]
                          : [AppColors.orange, AppColors.red],
                    ),
                  ),
                  child: isHead
                      ? Center(
                          child: Container(
                            width: cellWidth * 0.4,
                            height: cellHeight * 0.4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }),

            // Game Over overlay - more polished
            if (gameState.hasLost || gameState.isPaused)
              Container(
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.5),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        child: CustomIconButton(
                          onPressed: () {
                            AppRoutes.go(AppRoutes.home);
                          },
                          width: 48,
                          height: 48,
                          imagePath: 'assets/icons/back.svg',
                        ),
                      ),
                    ),
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
                                gameState.isPaused ? 'Pausa' : 'Perdió',
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

                          // Oferta de vidas extra (solo al perder y si hay un
                          // anuncio recompensado listo para mostrar).
                          if (gameState.hasLost &&
                              AdsService
                                  .instance
                                  .isRewardedInterstitialReady) ...[
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _offerExtraLives,
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
                                      'GANA VIDAS EXTRA',
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
