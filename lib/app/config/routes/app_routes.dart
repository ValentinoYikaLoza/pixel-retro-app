import 'package:get/get.dart';
import 'package:pixel_retro_app/app/features/home/presentation/screens/home_screen.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:pixel_retro_app/app/features/reward/presentation/screens/reward_screen.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/screens/shop_screen.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/screens/level_snake_game_screen.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/screens/snake_game_screen.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/screens/layout_view.dart';
import 'package:pixel_retro_app/app/shared/screens/ad_screen.dart';
import 'package:pixel_retro_app/app/shared/screens/wait_to_layout_screen.dart';
import 'package:pixel_retro_app/app/shared/screens/wait_to_game_screen.dart';
import 'package:pixel_retro_app/app/shared/screens/welcome_screen.dart';

class AppRoutes {
  // Tabs principales
  static const String root = '/';
  static const String leaderboard = '/leaderboard';
  static const String reward = '/reward';
  static const String shop = '/shop';

  // Flujo de bienvenida
  static const String waitToGame = '/wait-to-welcome-screen';
  static const String waitToLayout = '/wait-to-home-screen';
  static const String welcome = '/welcome-screen';

  // Snake Game
  static const String levelSnakeGame = '/level-snake-game';
  static const String snakeGame = '/snake-game';

  // Ads
  static const String adBanner = '/ad-banner';
  static const String adInterstitial = '/ad-interstitial';
  static const String adRewarded = '/ad-rewarded';

  static Future<void> go(
    String route, {
    Map<String, dynamic>? arguments,
  }) async {
    await Get.toNamed(route, arguments: arguments);
  }

  static final routes = [
    // Tabs
    GetPage(
      name: root,
      page: () => const LayoutView(child: HomeScreen()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: leaderboard,
      page: () => const LayoutView(child: LeaderboardScreen()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: reward,
      page: () => const LayoutView(child: RewardScreen()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: shop,
      page: () => const LayoutView(child: ShopScreen()),
      transition: Transition.fadeIn,
    ),

    // Flujo bienvenida
    GetPage(
      name: waitToGame,
      page: () => const WaitToGameScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: waitToLayout,
      page: () => const WaitToLayoutScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: welcome,
      page: () => const WelcomeScreen(),
      transition: Transition.size,
    ),

    // Snake Game
    GetPage(
      name: levelSnakeGame,
      page: () => const LevelSnakeGameScreen(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: snakeGame,
      page: () => const SnakeGameScreen(),
      transition: Transition.downToUp,
    ),
    // Ads
    GetPage(
      name: adBanner,
      page: () => const AdBannerScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adInterstitial,
      page: () => const AdInterstitialScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: adRewarded,
      page: () => const AdRewardedScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
