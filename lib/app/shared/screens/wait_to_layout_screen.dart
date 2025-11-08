import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';

class WaitToLayoutScreen extends StatefulWidget {
  const WaitToLayoutScreen({super.key});

  @override
  State<WaitToLayoutScreen> createState() => _WaitToLayoutScreenState();
}

class _WaitToLayoutScreenState extends State<WaitToLayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setScreenConfig();
    });

    Future.delayed(const Duration(seconds: 2), () {
      AppRoutes.go(AppRoutes.home);
    });
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.logoBackground);
    OrientationService.setPortrait();
    OrientationService.setEdgeToEdge();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: AppColors.logoBackground),
          child: Center(child: Image.asset('assets/images/logo.png')),
        ),
      ),
    );
  }
}
