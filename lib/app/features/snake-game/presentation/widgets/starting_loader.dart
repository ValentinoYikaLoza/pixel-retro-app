import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

/// Loader que se muestra mientras el servidor abre la partida (`startGame`) o
/// mientras se cierra al salir. Mantiene la estética de la app: tipografía pixel
/// con contorno y una "serpiente" de celdas que avanza sobre la grilla neón.
class StartingLoader extends StatefulWidget {
  const StartingLoader({
    super.key,
    this.title = 'INICIANDO',
    this.subtitle = 'Preparando el tablero',
  });

  /// Título pixel (sin los puntos animados, que se agregan solos).
  final String title;

  /// Texto secundario bajo la animación.
  final String subtitle;

  @override
  State<StartingLoader> createState() => _StartingLoaderState();
}

class _StartingLoaderState extends State<StartingLoader> {
  static const int _cells = 7;
  static const int _snakeLength = 4;

  Timer? _timer;
  int _head = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 160), (_) {
      setState(() => _head = (_head + 1) % _cells);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Distancia de la celda [index] respecto a la cabeza (0 = cabeza), o null si
  /// no forma parte del cuerpo de la serpiente en este frame.
  int? _segmentOffset(int index) {
    final offset = (_head - index) % _cells;
    final wrapped = offset < 0 ? offset + _cells : offset;
    return wrapped < _snakeLength ? wrapped : null;
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * (_head % 4);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Título con contorno (estilo pixel de la app).
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
          // Serpiente que avanza sobre la grilla.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_cells, (i) {
              final offset = _segmentOffset(i);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _Cell(offset: offset),
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

/// Una celda de la grilla del loader. Si [offset] no es null forma parte de la
/// serpiente (0 = cabeza, con el degradado naranja→rojo del juego); si es null
/// es una celda vacía con el borde neón tenue de la grilla.
class _Cell extends StatelessWidget {
  final int? offset;

  const _Cell({required this.offset});

  @override
  Widget build(BuildContext context) {
    final isBody = offset != null;
    final isHead = offset == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isBody ? null : AppColors.purple,
        gradient: isBody
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.orange, AppColors.red],
              )
            : null,
        borderRadius: BorderRadius.circular(isHead ? 6 : 4),
        border: Border.all(
          color: isBody
              ? Colors.transparent
              : AppColors.neonPurple.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: isBody
            ? [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.45),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
