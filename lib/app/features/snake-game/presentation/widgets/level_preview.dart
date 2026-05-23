import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';

/// Miniatura del tablero de un nivel: dibuja la grilla, las paredes y, si el
/// nivel tiene borde sólido, el marco. Refleja visualmente la complejidad
/// (más paredes / arena más chica / borde = nivel más difícil).
class LevelPreview extends StatelessWidget {
  final GameLevelEntity level;
  final double width;
  final double height;

  /// Muestra el punto de comida central (solo aplica al Snake).
  final bool showFood;

  const LevelPreview({
    super.key,
    required this.level,
    this.width = 180,
    this.height = 120,
    this.showFood = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _LevelPainter(level, showFood)),
    );
  }
}

class _LevelPainter extends CustomPainter {
  final GameLevelEntity level;
  final bool showFood;

  _LevelPainter(this.level, this.showFood);

  @override
  void paint(Canvas canvas, Size size) {
    final gw = level.gridWidth;
    final gh = level.gridHeight;
    if (gw <= 0 || gh <= 0) return;

    // Escala uniforme para conservar la proporción del tablero.
    final scale = min(size.width / gw, size.height / gh);
    final ox = (size.width - scale * gw) / 2;
    final oy = (size.height - scale * gh) / 2;
    final field = Rect.fromLTWH(ox, oy, scale * gw, scale * gh);

    // Fondo del tablero (oscuro para que resalten las paredes).
    canvas.drawRect(field, Paint()..color = AppColors.backgroundDark);

    // Paredes: relleno claro (amatista) con borde neón para que se vean nítidas
    // y reflejen la complejidad del nivel.
    final wallFill = Paint()..color = AppColors.amethyst;
    final wallEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale > 6 ? 1 : 0.5
      ..color = AppColors.neonPurple.withValues(alpha: 0.9);
    for (final w in level.walls) {
      final cell = Rect.fromLTWH(
        ox + w.dx * scale,
        oy + w.dy * scale,
        scale,
        scale,
      );
      canvas.drawRect(cell, wallFill);
      canvas.drawRect(cell.deflate(0.25), wallEdge);
    }

    // Comida de referencia (un punto) en el centro, como en la partida (Snake).
    if (showFood) {
      final cx = ox + (gw ~/ 2 + 0.5) * scale;
      final cy = oy + (gh ~/ 2 + 0.5) * scale;
      canvas.drawCircle(
        Offset(cx, cy),
        scale * 0.6,
        Paint()..color = AppColors.orange,
      );
    }

    // Marco: sólido (neón) si el borde mata; tenue si hay wrap-around.
    canvas.drawRect(
      field,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = level.wrapAround ? 1 : 2.5
        ..color = level.wrapAround
            ? AppColors.neonPurple.withValues(alpha: 0.25)
            : AppColors.neonPurple,
    );
  }

  @override
  bool shouldRepaint(_LevelPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.showFood != showFood;
}
