import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_retro_app/app/config/router/app_router.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/screens/snake_game_screen.dart';
import 'package:pixel_retro_app/app/shared/layouts/layout_view.dart';

final routerMobile = GoRouter(
  initialLocation: '/',
  navigatorKey: rootNavigatorKey,
  errorBuilder: (context, state) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AppRouter.go('/');
    });
    return const SizedBox.shrink();
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (context, state) {
        return const MaterialPage(child: LayoutView());
      },
    ),
    GoRoute(
      path: '/snake-game',
      builder: (context, state) {
        return const SnakeGameScreen();
      },
    ),
  ],
);
