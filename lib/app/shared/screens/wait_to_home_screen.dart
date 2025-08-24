import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class WaitToHomeScreen extends StatefulWidget {
  const WaitToHomeScreen({super.key});

  @override
  State<WaitToHomeScreen> createState() => _WaitToHomeScreenState();
}

class _WaitToHomeScreenState extends State<WaitToHomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      setScreenConfig();
      Get.toNamed('/');
    });
  }

  void setScreenConfig() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(systemNavigationBarColor: AppColors.orange),
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
