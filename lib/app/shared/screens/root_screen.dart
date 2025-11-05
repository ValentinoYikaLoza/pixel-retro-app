import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/home/presentation/providers/home_provider.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/providers/mission_provider.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';
import 'package:pixel_retro_app/app/features/time/presentation/providers/time_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getData() async {
    await Future.wait([
      // time
      ref.read(timeProvider.notifier).getTime(),

      // user
      ref.read(userProvider.notifier).getUser(),

      // home
      ref.read(homeProvider.notifier).getGames(),

      // leaderboard
      ref.read(leaderboardProvider.notifier).getUsers(),
      ref.read(leaderboardProvider.notifier).getDivisions(),

      // reward
      ref.read(missionProvider.notifier).getMissions(),

      // shop
      ref.read(shopProvider.notifier).getAdvertisements(),
      ref.read(shopProvider.notifier).getCoinShopItems(),
      ref.read(shopProvider.notifier).getLiveShopItems(),
    ]);

    AppRoutes.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.orange),
      child: Center(child: CircularProgressIndicator(color: AppColors.white)),
    );
  }
}
