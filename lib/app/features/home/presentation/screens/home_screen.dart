import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/home/presentation/providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  bool shouldStartAnimation = false;
  bool shouldRotate = false;
  double rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
  }

  void _startAnimation() {
    setState(() {
      shouldStartAnimation = true;
    });
  }

  void _startRotation() {
    setState(() {
      shouldRotate = true;
      rotationAngle = 2 * 3.14159; // Rotación completa (360° en radianes)
    });
  }

  void _handleAnimationComplete(String gameMode) {
    if (shouldRotate) {
      setState(() {
        shouldRotate = false;
        rotationAngle = 0.0;
      });

      // Pequeño delay antes de la navegación
      Future.delayed(Duration(milliseconds: 300), () {
        AppRoutes.go(AppRoutes.waitToGame, arguments: {'gameMode': gameMode});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    final hasGames = homeState.games.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          if (hasGames) ...[
            // --- Mostrar título del juego seleccionado ---
            Stack(
              children: [
                Text(
                  homeState.gameSelected?.title ?? '',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pixel',
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = AppColors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  homeState.gameSelected?.title ?? '',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pixel',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // --- Carousel ---
            AnimatedScale(
              scale: shouldStartAnimation ? 1.3 : 1.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              onEnd: () {
                if (shouldStartAnimation) {
                  _startRotation();
                  setState(() {
                    shouldStartAnimation = false;
                  });
                }
              },
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                turns: shouldRotate ? rotationAngle / (2 * 3.14159) : 0,
                onEnd: () => _handleAnimationComplete(
                  homeState.gameSelected?.name ?? '',
                ),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 271,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.7,
                    onPageChanged: (index, reason) {
                      ref
                          .read(homeProvider.notifier)
                          .selectGame(homeState.games[index].title);
                    },
                  ),
                  items: homeState.games.map((game) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: 271,
                          height: 271,
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.orange,
                              width: 4.0,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: _startAnimation,
                            child: Image.asset(
                              'assets/images/${game.name}.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ] else ...[
            // --- Mensaje cuando no hay juegos ---
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Stack(
                      children: [
                        Text(
                          "Los juegos no están disponibles\nen este momento",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pixel',
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = AppColors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Los juegos no están disponibles\nen este momento",
                          style: TextStyle(
                            color: AppColors.purple,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Pixel',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Text(
                      "Parece que estás offline. ¡Revisa tu conexión!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
