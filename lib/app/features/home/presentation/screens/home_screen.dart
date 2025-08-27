import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/home/presentation/providers/home_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_appbar.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).getGames();
    });
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

  // En HomeScreenState
  void _handleAnimationComplete(String gameMode) {
    if (shouldRotate) {
      setState(() {
        shouldRotate = false;
        rotationAngle = 0.0;
      });

      // Pequeño delay antes de la navegación
      Future.delayed(Duration(milliseconds: 300), () {
        Get.toNamed(
          '/wait-to-welcome-screen',
          arguments: {'nextScreen': '/welcome-screen', 'gameMode': gameMode},
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: CustomAppbar(),
      body: homeState.gameSelected != null || homeState.games.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                children: [
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
                      // Fill
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
                  AnimatedScale(
                    scale: shouldStartAnimation ? 1.3 : 1.0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    onEnd: () {
                      if (shouldStartAnimation) {
                        // Iniciar la rotación después de completar el escalado
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
                          initialPage: 0,
                          enableInfiniteScroll: false,
                          autoPlay: false,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(
                            milliseconds: 800,
                          ),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.7,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, reason) {
                            setState(() {
                              ref
                                  .read(homeProvider.notifier)
                                  .selectGame(homeState.games[index].title);
                            });
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
                                      offset: const Offset(0, 5),
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
                ],
              ),
            )
          : SizedBox(height: 0),
    );
  }
}
