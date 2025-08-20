import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_retro_app/app/config/router/router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> layoutShellNavigatorKey =
    GlobalKey<NavigatorState>();

Future<String?> internalGuard({required BuildContext context}) async {
  return null;
}

Future<String?> externalGuard() async {
  return null;
}

Future<String?> noWebGuard() async {
  return null;
}

class AppRouter {
  static GoRouter getAppRouter() {
    return routerMobile;
  }

  static go(String location) {
    routerMobile.go(location);
  }

  static push(String location) {
    routerMobile.push(location);
  }

  static pop() {
    routerMobile.pop();
  }
}
