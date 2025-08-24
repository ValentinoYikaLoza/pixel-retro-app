import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class WaitScreen extends StatefulWidget {
  const WaitScreen({super.key});

  @override
  State<WaitScreen> createState() => _WaitScreenState();
}

class _WaitScreenState extends State<WaitScreen> {
  Map<String, dynamic> arguments = {};

  @override
  void initState() {
    super.initState();

    // Verificar y castear los arguments inmediatamente
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      arguments = Get.arguments as Map<String, dynamic>;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setScreenConfig();
    });

    Future.delayed(const Duration(seconds: 1), () {
      final nextScreen = arguments['nextScreen']?.toString() ?? '/';
      final gameMode = arguments['gameMode']?.toString() ?? '';

      Get.toNamed(
        nextScreen,
        arguments: {
          'title': 'Bienvenido a $gameMode Game',
          'imagePath': 'assets/images/$gameMode.png',
          'nextScreen': '/level-$gameMode-game',
        },
      );
    });
  }

  void setScreenConfig() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(systemNavigationBarColor: AppColors.neonPurple),
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setScreenConfig();
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Get.toNamed('/');
          }
        },
        child: Scaffold(
          body: Center(
            child: Container(
              decoration: BoxDecoration(color: AppColors.backgroundDark),
            ),
          ),
        ),
      ),
    );
  }
}
