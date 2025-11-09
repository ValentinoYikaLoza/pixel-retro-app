import 'dart:async';

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
  String loadingText = "Cargando";
  Timer? _timer;
  int dotCount = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setScreenConfig();
    });

    // Animación de los puntitos
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() {
        dotCount = (dotCount + 1) % 4; // 0,1,2,3 → vuelve a 0
        loadingText = "Cargando${"." * dotCount}";
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      _timer?.cancel();
      AppRoutes.go(AppRoutes.home);
    });
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.logoBackground);
    OrientationService.setPortrait();
    OrientationService.setEdgeToEdge();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: AppColors.logoBackground),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20,
            children: [
              Image.asset('assets/images/logo.png'),
              Stack(
                children: [
                  Text(
                    loadingText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pixel',
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = AppColors.orange,
                    ),
                  ),
                  Text(
                    loadingText,
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pixel',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
