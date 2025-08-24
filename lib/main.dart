import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/app.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/constants/environment.dart';
import 'package:pixel_retro_app/app/config/theme/app_theme.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/screens/level_snake_game_screen.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/screens/snake_game_screen.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/screens/layout_view.dart';
import 'package:pixel_retro_app/app/shared/screens/wait_to_home_screen.dart';
import 'package:pixel_retro_app/app/shared/screens/wait_to_welcome_screen.dart';
import 'package:pixel_retro_app/app/shared/screens/welcome_screen.dart';
import 'package:pixel_retro_app/di.dart';

void main() async {
  await Environment.initEnvironment();
  WidgetsFlutterBinding.ensureInitialized();
  setup();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(systemNavigationBarColor: AppColors.orange),
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  });

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pixel Retro',
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/',
          page: () => LayoutView(),
          transitionDuration: Duration(milliseconds: 1500),
          transition: Transition.downToUp,
        ),
        GetPage(
          name: '/wait-to-welcome-screen',
          page: () => const WaitToWelcomeScreen(),
          transitionDuration: Duration(milliseconds: 800),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/wait-to-home-screen',
          page: () => const WaitToHomeScreen(),
          transitionDuration: Duration(milliseconds: 800),
          transition: Transition.cupertino,
        ),
        GetPage(
          name: '/welcome-screen',
          page: () => const WelcomeScreen(),
          transition: Transition.size,
          transitionDuration: Duration(milliseconds: 1200),
        ),
        GetPage(
          name: '/level-snake-game',
          page: () => const LevelSnakeGameScreen(),
          transition: Transition.zoom,
          transitionDuration: Duration(milliseconds: 1200),
        ),
        GetPage(
          name: '/snake-game',
          page: () => const SnakeGameScreen(),
          transition: Transition.downToUp,
          transitionDuration: Duration(milliseconds: 1200),
        ),
      ],
      theme: AppTheme.getTheme(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es')],
      builder: (context, child) {
        return App(child: child!);
      },
    );
  }
}
