import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/logic/pacman_maze.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/providers/pacman_game_provider.dart';

/// Tablero de Pac-Man: dibuja el laberinto/pellets/Pac con CustomPaint y captura
/// el swipe para fijar la dirección deseada. [onSwipe] recibe la dirección.
class PacmanBoard extends StatefulWidget {
  const PacmanBoard({
    super.key,
    required this.state,
    required this.onSwipe,
    this.overlay,
  });

  final PacmanGameState state;
  final ValueChanged<PacDir> onSwipe;
  final Widget? overlay;

  @override
  State<PacmanBoard> createState() => _PacmanBoardState();
}

class _PacmanBoardState extends State<PacmanBoard> {
  Offset? _start;
  static const double _threshold = 14;

  void _onUpdate(Offset current) {
    final start = _start;
    if (start == null) {
      _start = current;
      return;
    }
    final d = current - start;
    if (d.dx.abs() < _threshold && d.dy.abs() < _threshold) return;
    if (d.dx.abs() > d.dy.abs()) {
      widget.onSwipe(d.dx > 0 ? PacDir.right : PacDir.left);
    } else {
      widget.onSwipe(d.dy > 0 ? PacDir.down : PacDir.up);
    }
    _start = current; // permite encadenar flicks dentro del mismo arrastre
  }

  @override
  Widget build(BuildContext context) {
    final maze = widget.state.maze;
    if (maze == null) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: maze.width / maze.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neonPurple, width: 2),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (d) => _start = d.localPosition,
            onPanStart: (d) => _start = d.localPosition,
            onPanUpdate: (d) => _onUpdate(d.localPosition),
            onPanEnd: (_) => _start = null,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _PacmanPainter(widget.state)),
                ),
                if (widget.overlay != null)
                  Positioned.fill(child: widget.overlay!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PacmanPainter extends CustomPainter {
  _PacmanPainter(this.state);

  final PacmanGameState state;

  static const Color _wallColor = Color(0xFF3B3BCF); // azul laberinto
  static const Color _pelletColor = Color(0xFFFFE08A); // crema

  @override
  void paint(Canvas canvas, Size size) {
    final maze = state.maze;
    if (maze == null) return;
    final s = size.width / maze.width; // celda cuadrada

    // Paredes (rect redondeado) y puerta de la casa (línea rosa).
    final wallPaint = Paint()..color = _wallColor;
    final doorPaint = Paint()
      ..color = const Color(0xFFFFA9D9)
      ..strokeWidth = s * 0.18
      ..strokeCap = StrokeCap.round;
    for (var y = 0; y < maze.height; y++) {
      final row = maze.rows[y];
      for (var x = 0; x < maze.width; x++) {
        final c = row[x];
        if (c == '#') {
          final r = Rect.fromLTWH(x * s, y * s, s, s).deflate(s * 0.12);
          canvas.drawRRect(
            RRect.fromRectAndRadius(r, Radius.circular(s * 0.28)),
            wallPaint,
          );
        } else if (c == '=') {
          final cy = (y + 0.5) * s;
          canvas.drawLine(
            Offset(x * s + s * 0.1, cy),
            Offset(x * s + s * 0.9, cy),
            doorPaint,
          );
        }
      }
    }

    // Pellets.
    final pelletPaint = Paint()..color = _pelletColor;
    for (final k in maze.pellets) {
      final x = k % maze.width;
      final y = k ~/ maze.width;
      canvas.drawCircle(
        Offset((x + 0.5) * s, (y + 0.5) * s),
        s * 0.12,
        pelletPaint,
      );
    }

    // Power pellets (pulsan con el frame).
    final pulse = 0.5 + 0.5 * sin(state.frame * 0.2);
    final powerPaint = Paint()..color = _pelletColor;
    for (final k in maze.powerPellets) {
      final x = k % maze.width;
      final y = k ~/ maze.width;
      canvas.drawCircle(
        Offset((x + 0.5) * s, (y + 0.5) * s),
        s * (0.26 + 0.06 * pulse),
        powerPaint,
      );
    }

    // Pac-Man (círculo amarillo con boca animada que apunta a su dirección).
    final cx = (state.pacX + 0.5) * s;
    final cy = (state.pacY + 0.5) * s;
    final radius = s * 0.46;
    // Apertura de boca: onda triangular 0..1..0.
    final m = state.mouth;
    final open = (m < 0.5 ? m * 2 : (1 - m) * 2);
    final half = open * 0.30 * pi; // medio ángulo de la boca
    final base = switch (state.pacDir) {
      PacDir.right => 0.0,
      PacDir.down => pi / 2,
      PacDir.left => pi,
      PacDir.up => -pi / 2,
      PacDir.none => pi,
    };
    final pac = Paint()..color = AppColors.yellow;
    final path = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        base + half,
        2 * pi - 2 * half,
        false,
      )
      ..close();
    canvas.drawPath(path, pac);
  }

  @override
  bool shouldRepaint(_PacmanPainter old) =>
      old.state.frame != state.frame ||
      old.state.pacX != state.pacX ||
      old.state.pacY != state.pacY;
}
