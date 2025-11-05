import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.purple),
      child: Center(
        child: Stack(
          children: [
            Text(
              "Se encuentra sin conexión a internet, por favor inténtelo de nuevo más tarde",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pixel',
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4
                  ..color = AppColors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "Se encuentra sin conexión a internet, por favor inténtelo de nuevo más tarde",
              style: TextStyle(
                color: AppColors.purple,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pixel',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
