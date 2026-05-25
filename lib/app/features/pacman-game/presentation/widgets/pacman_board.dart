import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/logic/pacman_actors.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/logic/pacman_maze.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/providers/pacman_game_provider.dart';

/// Tablero de Pac-Man: dibuja el laberinto/pellets/Pac con CustomPaint. El
/// control por swipe se maneja a nivel de pantalla (para que funcione también
/// fuera del área del tablero), así que aquí no hay GestureDetector.
class PacmanBoard extends StatelessWidget {
  const PacmanBoard({super.key, required this.state, this.overlay});

  final PacmanGameState state;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final maze = state.maze;
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
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _PacmanPainter(state)),
              ),
              if (overlay != null) Positioned.fill(child: overlay!),
            ],
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

    // Fruta bonus (placeholder: cereza roja con tallo) hasta tener sprite.
    if (state.fruitActive) {
      final fx = (state.fruitX + 0.5) * s;
      final fy = (state.fruitY + 0.5) * s;
      canvas.drawCircle(
        Offset(fx - s * 0.12, fy + s * 0.08),
        s * 0.22,
        Paint()..color = const Color(0xFFE53935),
      );
      canvas.drawCircle(
        Offset(fx + s * 0.16, fy + s * 0.12),
        s * 0.18,
        Paint()..color = const Color(0xFFE53935),
      );
      canvas.drawLine(
        Offset(fx - s * 0.08, fy - s * 0.18),
        Offset(fx + s * 0.18, fy - s * 0.28),
        Paint()
          ..color = const Color(0xFF66BB6A)
          ..strokeWidth = s * 0.08
          ..strokeCap = StrokeCap.round,
      );
    }

    // Power-ups: solo la letra, grande y con diseño (halo + contorno) para que
    // se distinga sin necesidad de cápsula.
    for (final p in state.powerups) {
      final pc = Offset((p.tx + 0.5) * s, (p.ty + 0.5) * s);
      _drawPowerGlyph(canvas, _powerGlyph(p.type), pc, _powerColor(p.type), s);
    }

    // Fantasmas (placeholder: cuerpo de domo + ojos; frightened azul/flash;
    // comido = solo ojos).
    for (final g in state.ghosts) {
      _drawGhost(canvas, g, s);
    }

    // Jefe (más grande, con barra de vida).
    final boss = state.boss;
    if (boss != null) _drawBoss(canvas, boss, s);

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

    // Anillo de escudo (escudo listo o invulnerabilidad reciente). Parpadea
    // durante la invulnerabilidad.
    if (state.shieldActive || (state.invuln && (state.frame ~/ 6) % 2 == 0)) {
      canvas.drawCircle(
        Offset(cx, cy),
        radius + s * 0.18,
        Paint()
          ..color = const Color(0xFF4FC3F7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.12,
      );
    }
  }

  Color _powerColor(PacPower t) => switch (t) {
    PacPower.speed => const Color(0xFFFFA84A), // naranja
    PacPower.freeze => const Color(0xFF49E0E0), // cian
    PacPower.shield => const Color(0xFF4FC3F7), // azul
    PacPower.doublePoints => const Color(0xFF42D77D), // verde
    PacPower.magnet => const Color(0xFFB57BFF), // morado
  };

  String _powerGlyph(PacPower t) => switch (t) {
    PacPower.speed => 'V',
    PacPower.freeze => 'F',
    PacPower.shield => 'S',
    PacPower.doublePoints => 'x2',
    PacPower.magnet => 'M',
  };

  /// Dibuja la letra de un power-up grande, con halo de color y contorno
  /// oscuro, para que resalte (sin cápsula). Pulsa suavemente.
  void _drawPowerGlyph(Canvas canvas, String t, Offset center, Color color, double s) {
    final pulse = 1 + 0.08 * sin(state.frame * 0.25);
    final fs = (t.length > 1 ? s * 0.95 : s * 1.25) * pulse;

    TextPainter tp(TextStyle style) => TextPainter(
      text: TextSpan(text: t, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    // Capa 1: contorno + halo de color (glow).
    final outline = tp(
      TextStyle(
        fontSize: fs,
        fontFamily: 'Pixel',
        height: 1,
        shadows: [Shadow(color: color, blurRadius: s * 0.45)],
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.16
          ..color = AppColors.backgroundDark,
      ),
    );
    outline.paint(canvas, center - Offset(outline.width / 2, outline.height / 2));

    // Capa 2: relleno del color del power-up.
    final fill = tp(
      TextStyle(
        fontSize: fs,
        fontFamily: 'Pixel',
        height: 1,
        color: color,
      ),
    );
    fill.paint(canvas, center - Offset(fill.width / 2, fill.height / 2));
  }

  Color _ghostColor(GhostType t) => switch (t) {
    GhostType.blinky => const Color(0xFFFF3B3B), // rojo
    GhostType.pinky => const Color(0xFFFFB8E0), // rosa
    GhostType.inky => const Color(0xFF49E0E0), // cian
    GhostType.clyde => const Color(0xFFFFA84A), // naranja
  };

  void _drawGhost(Canvas canvas, Ghost g, double s) {
    final cx = (g.px + 0.5) * s;
    final cy = (g.py + 0.5) * s;
    final r = s * 0.46;
    final eaten = g.mode == GhostMode.eaten;

    if (!eaten) {
      Color body;
      if (g.mode == GhostMode.frightened) {
        // Parpadea blanco/azul en los últimos ~2s del frightened.
        final flashing =
            state.frightenedMs <= 2000 && ((state.frame ~/ 12) % 2 == 0);
        body = flashing ? Colors.white : const Color(0xFF2733D6);
      } else {
        body = _ghostColor(g.type);
      }
      // Cuerpo: domo (semicírculo superior) + base con 3 ondas.
      final left = cx - r;
      final right = cx + r;
      final top = cy - r;
      final bottom = cy + r;
      final path = Path()
        ..moveTo(left, bottom)
        ..lineTo(left, cy)
        ..arcTo(Rect.fromLTRB(left, top, right, top + 2 * r), pi, pi, false)
        ..lineTo(right, bottom);
      final w = (right - left) / 3;
      path
        ..lineTo(right - w * 0.5, bottom - r * 0.35)
        ..lineTo(right - w, bottom)
        ..lineTo(right - w * 1.5, bottom - r * 0.35)
        ..lineTo(left + w, bottom)
        ..lineTo(left + w * 0.5, bottom - r * 0.35)
        ..close();
      canvas.drawPath(path, Paint()..color = body);
    }

    // Ojos (blancos con pupila desplazada hacia la dirección). Frightened sin
    // pupila desplazada (mirada "asustada").
    final ex = g.dir.vec.x * r * 0.22;
    final ey = g.dir.vec.y * r * 0.22;
    final eyeR = r * 0.26;
    final pupR = r * 0.14;
    for (final sx in [-1.0, 1.0]) {
      final eyeC = Offset(cx + sx * r * 0.32, cy - r * 0.18);
      canvas.drawCircle(eyeC, eyeR, Paint()..color = Colors.white);
      final pupilColor = (g.mode == GhostMode.frightened)
          ? const Color(0xFF2733D6)
          : const Color(0xFF1B2A6B);
      canvas.drawCircle(
        eyeC + Offset(ex, ey),
        pupR,
        Paint()..color = pupilColor,
      );
    }
  }

  void _drawBoss(Canvas canvas, Boss b, double s) {
    final cx = (b.px + 0.5) * s;
    final cy = (b.py + 0.5) * s;
    final r = s * 0.85; // más grande que un fantasma normal
    final vulnerable = state.frightenedMs > 0;
    final body = vulnerable
        ? const Color(0xFF2733D6) // azul (vulnerable)
        : const Color(0xFF9B1B2E); // rojo oscuro (peligroso)

    final left = cx - r;
    final right = cx + r;
    final top = cy - r;
    final bottom = cy + r;
    final path = Path()
      ..moveTo(left, bottom)
      ..lineTo(left, cy)
      ..arcTo(Rect.fromLTRB(left, top, right, top + 2 * r), pi, pi, false)
      ..lineTo(right, bottom);
    final w = (right - left) / 3;
    path
      ..lineTo(right - w * 0.5, bottom - r * 0.32)
      ..lineTo(right - w, bottom)
      ..lineTo(right - w * 1.5, bottom - r * 0.32)
      ..lineTo(left + w, bottom)
      ..lineTo(left + w * 0.5, bottom - r * 0.32)
      ..close();
    canvas.drawPath(path, Paint()..color = body);

    // Ojos grandes mirando hacia Pac.
    final ex = b.dir.vec.x * r * 0.18;
    final ey = b.dir.vec.y * r * 0.18;
    for (final sx in [-1.0, 1.0]) {
      final eyeC = Offset(cx + sx * r * 0.34, cy - r * 0.15);
      canvas.drawCircle(eyeC, r * 0.24, Paint()..color = Colors.white);
      canvas.drawCircle(
        eyeC + Offset(ex, ey),
        r * 0.13,
        Paint()..color = const Color(0xFF1B2A6B),
      );
    }

    // Barra de vida encima.
    final barW = r * 1.8;
    final barH = s * 0.2;
    final barX = cx - barW / 2;
    final barY = top - s * 0.55;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barW, barH),
        Radius.circular(barH / 2),
      ),
      Paint()..color = AppColors.backgroundDark,
    );
    final frac = (b.hp / b.maxHp).clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barW * frac, barH),
        Radius.circular(barH / 2),
      ),
      Paint()..color = AppColors.emerald,
    );
  }

  @override
  bool shouldRepaint(_PacmanPainter old) =>
      old.state.frame != state.frame ||
      old.state.pacX != state.pacX ||
      old.state.pacY != state.pacY;
}
