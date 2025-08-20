import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(
        accentColor: AppColors.orange,
        backgroundColor: AppColors.backgroundDark,
      ),
      fontFamily: 'Poppins',
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
