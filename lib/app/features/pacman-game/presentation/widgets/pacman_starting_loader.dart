import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

/// Loader de Pac-Man (entrada / carga). Mantiene la estética de la app: título
/// pixel con contorno y una fila de pellets que se "come" en bucle.
class PacmanStartingLoader extends StatefulWidget {
  const PacmanStartingLoader({
    super.key,
    this.title = 'INICIANDO',
    this.subtitle = 'Preparando el laberinto',
  });

  final String title;
  final String subtitle;

  @override
  State<PacmanStartingLoader> createState() => _PacmanStartingLoaderState();
}

class _PacmanStartingLoaderState extends State<PacmanStartingLoader> {
  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
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
    const count = 6;
    final eaten = _tick % (count + 1);
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
            children: [
              const Icon(Icons.pie_chart, size: 24, color: AppColors.yellow),
              const SizedBox(width: 8),
              ...List.generate(count, (i) {
                final gone = i < eaten;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.circle,
                    size: 8,
                    color: gone
                        ? AppColors.yellow.withValues(alpha: 0.15)
                        : AppColors.yellow,
                  ),
                );
              }),
            ],
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
