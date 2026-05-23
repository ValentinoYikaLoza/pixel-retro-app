import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/home/presentation/screens/home_screen.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/screens/mission_screen.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/screens/shop_screen.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/screens/level_snake_game_screen.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/screens/snake_game_screen.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/screens/layout_view.dart';
import 'package:pixel_retro_app/app/shared/screens/ad_screen.dart';
import 'package:pixel_retro_app/app/shared/screens/root_screen.dart';
import 'package:pixel_retro_app/app/shared/screens/welcome_screen.dart';
import 'package:pixel_retro_app/app/shared/services/ads_service.dart';

/// Navigator raíz: permite navegar y abrir diálogos sin un `BuildContext`
/// (lo necesitan `AppRoutes.go` y `DialogService`).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.root,
  routes: [
    GoRoute(
      path: AppRoutes.root,
      pageBuilder: (context, state) => _fade(state, const RootScreen()),
    ),
    // Tabs principales (cada tab es una ruta que comparte LayoutView)
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) =>
          _fade(state, const LayoutView(child: HomeScreen())),
    ),
    GoRoute(
      path: AppRoutes.leaderboard,
      pageBuilder: (context, state) =>
          _fade(state, const LayoutView(child: LeaderboardScreen())),
    ),
    GoRoute(
      path: AppRoutes.mission,
      pageBuilder: (context, state) =>
          _fade(state, const LayoutView(child: MissionScreen())),
    ),
    GoRoute(
      path: AppRoutes.shop,
      pageBuilder: (context, state) =>
          _fade(state, const LayoutView(child: ShopScreen())),
    ),
    // Intro de marca al entrar a un juego (también hace el cambio a landscape;
    // el fade de la ruta enmascara la rotación).
    GoRoute(
      path: AppRoutes.welcome,
      pageBuilder: (context, state) =>
          _fade(state, WelcomeScreen(arguments: _argsOf(state))),
    ),
    // Snake game
    GoRoute(
      path: AppRoutes.levelSnakeGame,
      pageBuilder: (context, state) =>
          _scale(state, const LevelSnakeGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.snakeGame,
      pageBuilder: (context, state) {
        final level = (_argsOf(state)['level'] as int?) ?? 1;
        return _slideUp(state, SnakeGameScreen(level: level));
      },
    ),
    // Ads
    GoRoute(
      path: AppRoutes.adRewardedCoins,
      pageBuilder: (context, state) =>
          _fade(state, const AdScreen(type: AdType.rewardedCoins)),
    ),
    GoRoute(
      path: AppRoutes.adRewardedLives,
      pageBuilder: (context, state) =>
          _fade(state, const AdScreen(type: AdType.rewardedLives)),
    ),
  ],
);

Map<String, dynamic> _argsOf(GoRouterState state) {
  final extra = state.extra;
  return extra is Map<String, dynamic> ? extra : const {};
}

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    // 400ms cubre la animación de rotación del SO en los cambios de orientación.
    transitionDuration: const Duration(milliseconds: 400),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage<void> _scale(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        ScaleTransition(scale: animation, child: child),
  );
}

CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
  );
}
