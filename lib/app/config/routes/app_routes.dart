import 'package:pixel_retro_app/app/config/routes/app_router.dart';

class AppRoutes {
  const AppRoutes._();

  // Tabs principales
  static const String root = '/';
  static const String home = '/home';
  static const String leaderboard = '/leaderboard';
  static const String mission = '/mission';
  static const String shop = '/shop';

  // Intro de marca al entrar a un juego
  static const String welcome = '/welcome-screen';

  // Snake Game
  static const String levelSnakeGame = '/level-snake-game';
  static const String snakeGame = '/snake-game';

  // Tetris Game
  static const String levelTetrisGame = '/level-tetris-game';
  static const String tetrisGame = '/tetris-game';

  // Ads
  static const String adRewardedCoins = '/ad-rewardedCoins';
  static const String adRewardedLives = '/ad-rewardedLives';

  /// Navega reemplazando la ubicación actual (equivalente al flujo lineal
  /// previo). `arguments` viaja como `extra` de go_router.
  static void go(String route, {Object? arguments}) {
    appRouter.go(route, extra: arguments);
  }

  /// Ruta (path) actualmente activa.
  static String get currentLocation =>
      appRouter.routerDelegate.currentConfiguration.uri.path;
}
