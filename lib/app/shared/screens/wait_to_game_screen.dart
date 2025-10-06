import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';

class WaitToGameScreen extends StatefulWidget {
  const WaitToGameScreen({super.key});

  @override
  State<WaitToGameScreen> createState() => _WaitToGameScreenState();
}

class _WaitToGameScreenState extends State<WaitToGameScreen> {
  Map<String, dynamic> arguments = {};

  @override
  void initState() {
    super.initState();
    setScreenConfig();

    // Verificar y castear los arguments inmediatamente
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      arguments = Get.arguments as Map<String, dynamic>;
    }

    Future.delayed(const Duration(seconds: 1), () {
      final gameMode = arguments['gameMode']?.toString() ?? '';

      AppRoutes.go(
        AppRoutes.welcome,
        arguments: {
          'title': 'Bienvenido a $gameMode Game',
          'imagePath': 'assets/images/$gameMode.png',
          'nextScreen': '/level-$gameMode-game',
        },
      );
    });
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.neonPurple);
    OrientationService.setLandscape();
    OrientationService.setImmersiveMode();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Container(
            decoration: BoxDecoration(color: AppColors.backgroundDark),
          ),
        ),
      ),
    );
  }
}
