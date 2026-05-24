import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

/// Loader de Pixel Invaders (entrada / carga). Mantiene la estética de la app:
/// título pixel con contorno y una fila de invasores que parpadea.
class InvadersStartingLoader extends StatefulWidget {
  const InvadersStartingLoader({
    super.key,
    this.title = 'INICIANDO',
    this.subtitle = 'Preparando la invasión',
  });

  final String title;
  final String subtitle;

  @override
  State<InvadersStartingLoader> createState() => _InvadersStartingLoaderState();
}

class _InvadersStartingLoaderState extends State<InvadersStartingLoader> {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 350), (_) {
      setState(() => _tick++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * (_tick % 4);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Text(
                '${widget.title}$dots',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = AppColors.neonPurple,
                ),
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final on = (_tick + i) % 2 == 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  Icons.videogame_asset,
                  size: 22,
                  color: on ? AppColors.emerald : AppColors.emerald.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            widget.subtitle,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
