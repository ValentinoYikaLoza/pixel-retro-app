import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.time,
    required this.color,
    this.fontSize = 18,
    this.showTheTextComplete = false,
  });

  final String time;
  final Color color;
  final double fontSize;
  final bool showTheTextComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: showTheTextComplete ? 5 : 10,
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
        Text(
          '${showTheTextComplete ? "QUEDAN " : ""}$time',
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
