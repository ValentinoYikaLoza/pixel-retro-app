import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/app.dart';
import 'package:pixel_retro_app/app/config/constants/environment.dart';
import 'package:pixel_retro_app/app/config/router/app_router.dart';
import 'package:pixel_retro_app/app/config/theme/app_theme.dart';
import 'package:pixel_retro_app/di.dart';

void main() async {
  await Environment.initEnvironment();
  WidgetsFlutterBinding.ensureInitialized();
  setup();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.blue.shade500,
    ),
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pixel Retro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      routerConfig: AppRouter.getAppRouter(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es')],
      builder: (context, child) {
        return App(child: child!);
      },
    );
  }
}
