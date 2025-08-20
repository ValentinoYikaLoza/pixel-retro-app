import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_retro_app/app/config/router/app_router.dart';
import 'package:pixel_retro_app/app/shared/layouts/layout.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_appbar.dart';

final routerMobile = GoRouter(
  initialLocation: '/home',
  navigatorKey: rootNavigatorKey,
  errorBuilder: (context, state) {
    //** rutas 404 */
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AppRouter.go('/');
    });
    return const SizedBox.shrink();
  },
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return Layout(child: child);
      },
      navigatorKey: layoutShellNavigatorKey,
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppbar(),
              body: Center(child: Text('Welcome to the Home Page!')),
            );
          },
        ),
        GoRoute(
          path: '/leaderboard',
          builder: (context, state) {
            return Scaffold(
              body: Center(child: Text('Welcome to the Leaderboard Page!')),
            );
          },
        ),
        GoRoute(
          path: '/rewards',
          builder: (context, state) {
            return Scaffold(
              body: Center(child: Text('Welcome to the Rewards Page!')),
            );
          },
        ),
        GoRoute(
          path: '/shop',
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppbar(isShopView: true),
              body: Center(child: Text('Welcome to the Shop Page!')),
            );
          },
        ),
      ],
    ),
  ],
);
