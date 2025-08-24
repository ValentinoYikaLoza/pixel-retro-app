import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Map<String, dynamic> arguments = {};
  String title = '';
  String imagePath = '';

  @override
  void initState() {
    super.initState();

    // Verificar y castear los arguments inmediatamente
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      arguments = Get.arguments as Map<String, dynamic>;
    }

    title = arguments['title']?.toString() ?? '';
    imagePath = arguments['imagePath']?.toString() ?? '';

    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.toNamed(arguments['nextScreen']?.toString() ?? '/');
    });
  }

  void setScreenConfig() {
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
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              border: Border.all(color: AppColors.neonPurple, width: 5),
            ),
            child: Column(
              spacing: 20,
              children: [
                Stack(
                  children: [
                    Text(
                      title.isNotEmpty
                          ? '${title[0].toUpperCase()}${title.substring(1)}'
                          : '',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pixel',
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = AppColors.neonPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Fill
                    Text(
                      title.isNotEmpty
                          ? '${title[0].toUpperCase()}${title.substring(1)}'
                          : '',
                      style: TextStyle(
                        color: AppColors.purple,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pixel',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonPurple, width: 2),
                  ),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
