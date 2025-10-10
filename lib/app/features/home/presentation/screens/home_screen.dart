import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
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
        AppRoutes.go(AppRoutes.waitToGame, arguments: {'gameMode': gameMode});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    final hasGames = homeState.games.isNotEmpty;

    return Scaffold(
      appBar: CustomAppbar(),
      body: Center(
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

              // Expanded(
              //   child: CustomScrollView(
              //     slivers: [
              //       SliverList(
              //         delegate: SliverChildListDelegate([
              //           stats.when(
              //             data: (stats) => Card(
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     'User stats',
              //                     style: TextStyle(
              //                       color: AppColors.purple,
              //                       fontSize: 24,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                     textAlign: TextAlign.center,
              //                   ),
              //                   Text(
              //                     '🪙 Monedas: ${stats.coins}',
              //                     style: TextStyle(
              //                       color: AppColors.yellow,
              //                       fontSize: 15,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                   Text(
              //                     '❤️ Vidas: ${stats.lives}',
              //                     style: TextStyle(
              //                       color: AppColors.red,
              //                       fontSize: 15,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                   Text(
              //                     '🔥 Racha: ${stats.streak}',
              //                     style: TextStyle(
              //                       color: AppColors.orange,
              //                       fontSize: 15,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //             loading: () => const Text('Cargando estadísticas...'),
              //             error: (e, _) => Text('Error: $e'),
              //           ),
              //           missions.when(
              //             data: (missions) => Card(
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     'User missions',
              //                     style: TextStyle(
              //                       color: AppColors.purple,
              //                       fontSize: 24,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                     textAlign: TextAlign.center,
              //                   ),
              //                   if (missions.dailyRewards.isNotEmpty) ...[
              //                     Text(
              //                       'Misiones diarias: ${missions.dailyRewards.length}',
              //                       style: TextStyle(
              //                         color: AppColors.orange,
              //                         fontSize: 15,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                     ),
              //                     for (var mission in missions.dailyRewards)
              //                       Text(
              //                         '🎯 ${mission.description}',
              //                         style: TextStyle(
              //                           color:
              //                               mission.isClaimed ==
              //                                   RewardState.claimed
              //                               ? AppColors.emerald
              //                               : AppColors.orange,
              //                           fontSize: 15,
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                     Divider(color: AppColors.orange),
              //                   ] else ...[
              //                     Text(
              //                       'Misiones diarias:\n🎯 Sin misiones',
              //                       style: TextStyle(
              //                         color: AppColors.orange,
              //                         fontSize: 15,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                     ),
              //                   ],
              //                   Text(
              //                     'Misiones semanales: 1\n🎯 ${missions.weeklyReward.description}',
              //                     style: TextStyle(
              //                       color: AppColors.orange,
              //                       fontSize: 15,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                   Text(
              //                     'Misiones mensuales: 1\n🎯 ${missions.monthlyReward.description}',
              //                     style: TextStyle(
              //                       color: AppColors.orange,
              //                       fontSize: 15,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //             loading: () => const Text('Cargando misiones...'),
              //             error: (e, _) => Text('Error: $e'),
              //           ),
              //         ]),
              //       ),
              //     ],
              //   ),
              // ),
            ] else ...[
              // --- Mensaje cuando no hay juegos ---
              Stack(
                children: [
                  Text(
                    "No hay juegos disponibles",
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
                    "No hay juegos disponibles",
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
            ],
          ],
        ),
      ),
    );
  }
}
