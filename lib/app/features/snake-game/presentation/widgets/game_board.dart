import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  GameBoardState createState() => GameBoardState();
}

class GameBoardState extends ConsumerState<GameBoard> {
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
                                color: AppColors.neonPurple.withOpacity(0.3),
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
                      color: AppColors.neonPurple.withOpacity(0.5),
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
                        color: Colors.black.withOpacity(0.2),
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
                color: Colors.black.withOpacity(0.5),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed('/');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, left: 20),
                          child: SvgPicture.asset(
                            'assets/icons/back.svg',
                            width: 48,
                            colorFilter: ColorFilter.mode(
                              AppColors.neonPurple,
                              BlendMode.srcIn,
                            ),
                          ),
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
                        ],
                      ),
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
