import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/game_board.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/joystick_control.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/starting_loader.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/confirm_dialog.dart';

class SnakeGameScreen extends ConsumerStatefulWidget {
  final int level;

  const SnakeGameScreen({super.key, this.level = 1});

  @override
  SnakeGameScreenState createState() => SnakeGameScreenState();
}

class SnakeGameScreenState extends ConsumerState<SnakeGameScreen> {
  @override
  void initState() {
    super.initState();
    setScreenConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Abre la partida del nivel en el servidor (consume vida) y arranca.
      ref.read(snakeGameProvider.notifier).startGame(level: widget.level);
    });

    // Precargamos los anuncios full-screen para que estén listos al terminar:
    // el interstitial se mostrará al salir y el rewarded interstitial se ofrece
    // al perder.
    AdsService.instance.preloadInterstitial();
    AdsService.instance.preloadRewardedInterstitial();
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.neonPurple);
    OrientationService.setLandscape();
    OrientationService.setImmersiveMode();
  }

  void _exit() {
    // Confirma antes de abandonar (avisa que se pierde vida y progreso).
    final st = ref.read(snakeGameProvider);
    final notifier = ref.read(snakeGameProvider.notifier);
    confirmGameExit(
      isLost: st.hasLost,
      isPaused: st.isPaused,
      togglePause: notifier.togglePause,
      onLeave: () async {
        // Muestra el loader de salida mientras se cierra la sesión, luego sale.
        await notifier.exitGame();
        AppRoutes.go(AppRoutes.levelSnakeGame);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(snakeGameProvider);
    final userState = ref.watch(userProvider);

    // Si no se pudo iniciar (sin vidas / error), avisa y va a la tienda.
    ref.listen(snakeGameProvider.select((s) => s.startFailed), (_, failed) {
      if (failed == true) {
        SnackbarService.show(
          gameState.startError ?? 'No se pudo iniciar la partida',
          type: SnackbarType.error,
        );
        AppRoutes.go(AppRoutes.shop);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _exit();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setScreenConfig();
          },
          child: Container(
            width: double.infinity,
            // Margen para que el board flote y no toque los bordes de pantalla.
            margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.neonPurple, width: 4),
            ),
            child: gameState.isExiting
                ? const StartingLoader(
                    title: 'SALIENDO',
                    subtitle: 'Cerrando la partida',
                  )
                : gameState.isStarting
                ? const StartingLoader()
                : Row(
                    children: [
                      Expanded(flex: 3, child: GameBoard()),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppColors.neonPurple,
                                width: 5,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Puntos (top)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
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

                              // Joystick analógico (movimiento fluido).
                              JoystickControl(
                                onDirectionChanged: (direction) => ref
                                    .read(snakeGameProvider.notifier)
                                    .changeDirection(direction),
                                onPauseChanged: () {
                                  ref
                                      .read(snakeGameProvider.notifier)
                                      .togglePause();
                                },
                                onLostChanged: () {
                                  ref
                                      .read(snakeGameProvider.notifier)
                                      .resetGame();
                                },
                              ),

                              // Vidas (bottom)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
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
