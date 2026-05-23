import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_icon_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';

class LevelSnakeGameScreen extends StatefulWidget {
  const LevelSnakeGameScreen({super.key});

  @override
  State<LevelSnakeGameScreen> createState() => _LevelSnakeGameScreenState();
}

class _LevelSnakeGameScreenState extends State<LevelSnakeGameScreen> {
  List<Color> borderColors = [AppColors.neonPurple];
  Color borderColor = AppColors.neonPurple;

  @override
  void initState() {
    super.initState();
    setScreenConfig();
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.neonPurple);
    OrientationService.setLandscape();
    OrientationService.setImmersiveMode();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setScreenConfig();
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            AppRoutes.go(AppRoutes.home);
          }
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              border: Border.all(color: borderColor, width: 5),
            ),
            child: Stack(
              children: [
                // Ícono de retroceso en la esquina superior izquierda
                Positioned(
                  top: 0,
                  left: 0,
                  child: CustomIconButton(
                    onPressed: () {
                      AppRoutes.go(AppRoutes.home);
                    },
                    width: 48,
                    height: 48,
                    imagePath: 'assets/icons/back.svg',
                  ),
                ),
                // Texto centrado en la parte superior
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Stack(
                      children: [
                        // Texto con borde
                        Text(
                          'LEVEL 1',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = borderColor,
                          ),
                        ),
                        // Texto de relleno
                        Text(
                          'LEVEL 1',
                          style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // map
                Align(
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: const Offset(0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // change the color
                            setState(() {
                              borderColor = borderColor == borderColors[0]
                                  ? borderColors[1]
                                  : borderColors[0];
                            });
                          },
                          child: SvgPicture.asset(
                            'assets/icons/arrow-left.svg',
                            width: 48,
                          ),
                        ),
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            color: AppColors.purple,
                            border: Border.all(color: borderColor, width: 0.5),
                          ),
                          child: Column(
                            children: List.generate(10, (rowIndex) {
                              return Expanded(
                                child: Row(
                                  children: List.generate(10, (colIndex) {
                                    return Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: borderColor,
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
                        GestureDetector(
                          onTap: () {
                            // change the color
                            setState(() {
                              borderColor = borderColor == borderColors[0]
                                  ? borderColors[1]
                                  : borderColors[0];
                            });
                          },
                          child: SvgPicture.asset(
                            'assets/icons/arrow-right.svg',
                            width: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: CustomTextButton(
                      width: 150,
                      height: 48,
                      radius: 15,
                      onPressed: () {
                        AppRoutes.go(AppRoutes.snakeGame);
                      },
                      label: 'JUGAR',
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
