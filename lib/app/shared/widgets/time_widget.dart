import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.time,
    required this.unit,
    required this.color,
    this.fontSize = 18,
    this.showTheTextComplete = false,
  });

  final int time;
  final String unit;
  final Color color;
  final double fontSize;
  final bool showTheTextComplete;

  @override
  Widget build(BuildContext context) {
    // Condición: no mostrar nada si no hay tiempo o unidad
    if (time <= 0 || unit.isEmpty) {
      return Stack(
        children: [
          Text(
            "Sin tiempo disponible",
            style: TextStyle(
              fontSize: fontSize,
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
            "Sin tiempo disponible",
            style: TextStyle(
              color: AppColors.purple,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pixel',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Spin(
          infinite: true,
          child: SvgPicture.asset(
            'assets/icons/clock.svg',
            width: fontSize + 2,
            height: fontSize + 2,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${showTheTextComplete ? "QUEDAN " : ""}$time $unit',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
