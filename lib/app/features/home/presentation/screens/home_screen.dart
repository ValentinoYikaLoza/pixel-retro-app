import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/home/presentation/providers/home_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_appbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).initGames();
    });
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
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 271,
                      initialPage: 0,
                      enableInfiniteScroll: false,
                      autoPlay: false,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
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
                            child: Image.asset(
                              game.imagePath,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator(color: AppColors.orange)),
    );
  }
}
