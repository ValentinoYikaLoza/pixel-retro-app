import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/game_board.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/game_control.dart';

class SnakeGameScreen extends ConsumerStatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  SnakeGameScreenState createState() => SnakeGameScreenState();
}

class SnakeGameScreenState extends ConsumerState<SnakeGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(snakeGameProvider.notifier).initGame();
      setScreenOrientation();
    });
  }

  void setScreenOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setScreenOrientation();
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Get.toNamed('/');
          }
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              border: Border.all(color: AppColors.neonPurple, width: 5),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: GameBoard()),
                Expanded(
                  child: GameControl(
                    onDirectionChanged: (direction) => ref
                        .read(snakeGameProvider.notifier)
                        .changeDirection(direction),
                    onPauseChanged: () {
                      ref.read(snakeGameProvider.notifier).togglePause();
                    },
                    onLostChanged: () {
                      ref.read(snakeGameProvider.notifier).resetGame();
                    },
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
