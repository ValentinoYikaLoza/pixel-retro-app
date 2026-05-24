import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_defs.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/providers/invaders_game_provider.dart';

/// Tablero de Pixel Invaders: dibuja el campo con CustomPaint y captura el
/// arrastre para mover la nave. [onMove] recibe la fracción horizontal (0..1).
class InvadersBoard extends StatelessWidget {
  const InvadersBoard({
    super.key,
    required this.state,
    required this.onMove,
    this.overlay,
  });

  final InvadersGameState state;
  final ValueChanged<double> onMove;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kFieldW / kFieldH,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.neonPurple, width: 3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              void handle(Offset local) => onMove((local.dx / w).clamp(0.0, 1.0));
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => handle(d.localPosition),
                onPanStart: (d) => handle(d.localPosition),
                onPanUpdate: (d) => handle(d.localPosition),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _InvadersPainter(state)),
                    ),
                    if (overlay != null) Positioned.fill(child: overlay!),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InvadersPainter extends CustomPainter {
  _InvadersPainter(this.state);

  final InvadersGameState state;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / kFieldW; // escala uniforme
    final paint = Paint();

    void fillRect(double cx, double cy, double w, double h, Color color, {double r = 1.5}) {
      paint.color = color;
      final rect = Rect.fromCenter(
        center: Offset(cx * s, cy * s),
        width: w * s,
        height: h * s,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)), paint);
    }

    // Búnkeres.
    for (final c in state.bunkers) {
      fillRect(c.dx, c.dy, state.bunkerCell, state.bunkerCell, AppColors.emerald.withValues(alpha: 0.85), r: 0.5);
    }

    // Invasores.
    for (final inv in state.invaders) {
      final color = inv.diving ? AppColors.orange : enemyColor(inv.type);
      fillRect(inv.x, inv.y, kInvW, kInvH, color, r: 2);
      // "ojos" pixel.
      paint.color = AppColors.backgroundDark;
      canvas.drawRect(
        Rect.fromCenter(center: Offset((inv.x - 4) * s, (inv.y - 1) * s), width: 3 * s, height: 3 * s),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset((inv.x + 4) * s, (inv.y - 1) * s), width: 3 * s, height: 3 * s),
        paint,
      );
    }

    // Jefe.
    final boss = state.boss;
    if (boss != null) {
      fillRect(boss.x, boss.y, 60, 34, AppColors.red, r: 4);
      fillRect(boss.x, boss.y - 2, 40, 10, AppColors.backgroundDark, r: 2);
      // Barra de vida.
      final frac = (boss.hp / boss.maxHp).clamp(0.0, 1.0);
      fillRect(kFieldW / 2, 14, 120, 6, AppColors.backgroundDark, r: 2);
      paint.color = AppColors.emerald;
      final barRect = Rect.fromCenter(
        center: Offset((kFieldW / 2 - 60 * (1 - frac)) * s, 14 * s),
        width: 120 * frac * s,
        height: 6 * s,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(barRect, Radius.circular(2 * s)), paint);
    }

    // OVNI.
    final ufo = state.ufo;
    if (ufo != null) {
      fillRect(ufo.x, 24, 28, 12, AppColors.yellow, r: 6);
    }

    // Power-ups (cápsulas con letra).
    for (final p in state.powerups) {
      fillRect(p.x, p.y, 16, 16, powerUpColor(p.type), r: 4);
      _text(canvas, powerUpGlyph(p.type), Offset(p.x * s, p.y * s), 10 * s, AppColors.backgroundDark);
    }

    // Balas.
    for (final b in state.playerBullets) {
      fillRect(b.x, b.y, 3, 12, AppColors.white, r: 1);
    }
    for (final b in state.enemyBullets) {
      fillRect(b.x, b.y, 4, 12, AppColors.red, r: 1);
    }

    // Nave + escudo.
    if (state.shieldActive) {
      paint
        ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s;
      canvas.drawCircle(Offset(state.shipX * s, kShipY * s), 24 * s, paint);
      paint.style = PaintingStyle.fill;
    }
    // Cuerpo de la nave (cañón + base).
    fillRect(state.shipX, kShipY + 2, kShipW, 8, AppColors.neonPurple, r: 2);
    fillRect(state.shipX, kShipY - 5, 8, 8, AppColors.purple, r: 2);
  }

  void _text(Canvas canvas, String t, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_InvadersPainter oldDelegate) =>
      oldDelegate.state.frame != state.frame ||
      oldDelegate.state.shipX != state.shipX;
}
