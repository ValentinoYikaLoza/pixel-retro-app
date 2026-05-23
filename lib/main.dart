import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/app.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/constants/environment.dart';
import 'package:pixel_retro_app/app/config/constants/storage_keys.dart';
import 'package:pixel_retro_app/app/config/theme/app_theme.dart';
import 'package:pixel_retro_app/app/config/routes/app_router.dart';
import 'package:pixel_retro_app/app/shared/services/consent_service.dart';
import 'package:pixel_retro_app/app/shared/services/internet_service.dart';
import 'package:pixel_retro_app/app/shared/services/storage_service.dart';
import 'package:pixel_retro_app/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();

  await StorageService.set<String>(StorageKeys.userId, '1');
  final userId = await StorageService.get<String>(StorageKeys.userId) ?? '';

  // Pide el consentimiento de privacidad (UMP) y, cuando se resuelve,
  // inicializa el SDK de anuncios. No se espera (await) para no bloquear el
  // arranque: el formulario, si aplica, se muestra sobre la primera pantalla.
  ConsentService.instance.gatherConsentThenInitAds();

  // ⬇️ Aquí inicializamos la escucha en tiempo real
  await InternetService.instance.initialize();

  setup(userId: userId);

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.logoBackground,
      ),
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
    return MaterialApp.router(
      title: 'Pixel Retro',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.getTheme(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es')],
      builder: (context, child) => App(child: child!),
    );
  }
}
