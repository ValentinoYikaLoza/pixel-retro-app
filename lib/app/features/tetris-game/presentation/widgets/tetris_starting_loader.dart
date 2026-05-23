import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/logic/tetromino.dart';

/// Loader mientras el servidor abre la partida de Tetris. Mantiene la estética
/// de la app: título pixel con contorno y una pieza que cae en una mini grilla.
class TetrisStartingLoader extends StatefulWidget {
  const TetrisStartingLoader({super.key});

  @override
  State<TetrisStartingLoader> createState() => _TetrisStartingLoaderState();
}

class _TetrisStartingLoaderState extends State<TetrisStartingLoader> {
  static const int _cols = 4;
  static const int _rows = 6;
  static const double _cell = 20;

  Timer? _timer;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 140), (_) {
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
    final type =
        PieceType.values[(_tick ~/ (_rows + 1)) % PieceType.values.length];
    final row = _tick % (_rows + 1); // la pieza baja y sale por abajo

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Text(
                'INICIANDO$dots',
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
              const Text(
                'INICIANDO',
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pixel',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: _cols * _cell,
            height: _rows * _cell,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.neonPurple, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomPaint(painter: _FallPainter(type, row)),
          ),
          const SizedBox(height: 20),
          Text(
            'Preparando el tablero',
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

class _FallPainter extends CustomPainter {
  final PieceType type;
  final int row;

  _FallPainter(this.type, this.row);

  @override
  void paint(Canvas canvas, Size size) {
    const cols = _TetrisStartingLoaderState._cols;
    final cell = size.width / cols;
    final shape = Tetromino.shapes[type]![0];

    // Ancho de la pieza para centrarla horizontalmente.
    var minX = 4, maxX = 0;
    for (final c in shape) {
      minX = c[0] < minX ? c[0] : minX;
      maxX = c[0] > maxX ? c[0] : maxX;
    }
    final offX = ((cols - (maxX - minX + 1)) / 2).floor() - minX;
    final color = Tetromino.colors[type]!;

    for (final c in shape) {
      final ax = c[0] + offX;
      final ay = c[1] + row - 1;
      if (ay < 0) continue;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(ax * cell + 0.5, ay * cell + 0.5, cell - 1, cell - 1),
        Radius.circular(cell * 0.18),
      );
      canvas.drawRRect(rect, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_FallPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.row != row;
}
