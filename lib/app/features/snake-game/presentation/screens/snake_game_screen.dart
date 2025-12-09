import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/game_board.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/game_control.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';

class SnakeGameScreen extends ConsumerStatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  SnakeGameScreenState createState() => SnakeGameScreenState();
}

class SnakeGameScreenState extends ConsumerState<SnakeGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(snakeGameProvider.notifier).initGame();
    });
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.neonPurple);
    OrientationService.setLandscape();
    OrientationService.setImmersiveMode();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(snakeGameProvider);
    final userState = ref.watch(userProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          AppRoutes.go(AppRoutes.waitToLayout);
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            setScreenConfig();
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              border: Border.all(color: AppColors.neonPurple, width: 5),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: GameBoard()),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.neonPurple, width: 5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Puntos (top)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Text(
                                    'Puntos',
                                    style: TextStyle(
                                      fontSize: 36,
                                      height: 36 / 36,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Pixel',
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 4
                                        ..color = AppColors.neonPurple,
                                    ),
                                  ),
                                  Text(
                                    'Puntos',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: 36,
                                      height: 36 / 36,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Pixel',
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${gameState.score}',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Control del juego (centro bajo)
                        Transform.translate(
                          offset: Offset(0, 0),
                          child: GameControl(
                            onDirectionChanged: (direction) => ref
                                .read(snakeGameProvider.notifier)
                                .changeDirection(direction),
                            onPauseChanged: () {
                              ref
                                  .read(snakeGameProvider.notifier)
                                  .togglePause();
                            },
                            onLostChanged: () {
                              ref.read(snakeGameProvider.notifier).resetGame();
                            },
                          ),
                        ),

                        // Vidas (bottom)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Text(
                                    'Vidas',
                                    style: TextStyle(
                                      fontSize: 36,
                                      height: 36 / 36,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Pixel',
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 4
                                        ..color = AppColors.neonPurple,
                                    ),
                                  ),
                                  Text(
                                    'Vidas',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: 36,
                                      height: 36 / 36,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Pixel',
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${userState.lives}',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
