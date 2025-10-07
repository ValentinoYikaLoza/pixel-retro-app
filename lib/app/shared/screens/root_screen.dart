import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/home/presentation/providers/home_provider.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/providers/mission_provider.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});

  @override
  RootScreenState createState() => RootScreenState();
}

class RootScreenState extends ConsumerState<RootScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    await Future.wait([
      // user
      ref.read(userProvider.notifier).getUserData(),

      // home
      ref.read(homeProvider.notifier).getGames(),

      // leaderboard
      ref.read(leaderboardProvider.notifier).getUsers(),
      ref.read(leaderboardProvider.notifier).getDivisions(),
      ref.read(leaderboardProvider.notifier).getCurrentUser(),
      ref.read(leaderboardProvider.notifier).getCurrentDivision(),
      ref.read(leaderboardProvider.notifier).getTimeLeft(),

      // reward
      ref.read(missionProvider.notifier).getMissions(),
      ref.read(missionProvider.notifier).getTimeLeftList(),
      ref.read(missionProvider.notifier).getCurrentMonth(),

      // shop
      ref.read(shopProvider.notifier).getAdvertisements(),
      ref.read(shopProvider.notifier).getCoinShopItems(),
      ref.read(shopProvider.notifier).getLiveShopItems(),
    ]);
    print('DATA RECIBIDAS');

    // Cuando todas las peticiones acaben:
    AppRoutes.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.white),
      child: Center(child: CircularProgressIndicator(color: Colors.black)),
    );
  }
}
