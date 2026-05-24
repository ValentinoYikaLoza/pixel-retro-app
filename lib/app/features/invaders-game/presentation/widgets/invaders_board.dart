import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_defs.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_sprites.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/providers/invaders_game_provider.dart';

/// Tablero de Pixel Invaders: dibuja el campo con CustomPaint (sprites
/// rasterizados) y captura el arrastre para mover la nave. [onMove] recibe la
/// fracción horizontal (0..1).
class InvadersBoard extends StatelessWidget {
  const InvadersBoard({
    super.key,
    required this.state,
    required this.sprites,
    required this.onMove,
    this.overlay,
  });

  final InvadersGameState state;
  final InvadersSprites sprites;
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
                      child: CustomPaint(
                        painter: _InvadersPainter(state, sprites),
                      ),
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
  _InvadersPainter(this.state, this.sprites);

  final InvadersGameState state;
  final InvadersSprites sprites;

  final Paint _imgPaint = Paint()..filterQuality = FilterQuality.medium;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / kFieldW; // escala uniforme

    void img(
      ui.Image? im,
      double cx,
      double cy,
      double boxW,
      double boxH, {
      bool fill = false,
    }) {
      if (im == null) return;
      final iw = im.width.toDouble();
      final ih = im.height.toDouble();
      double dw, dh;
      if (fill) {
        dw = boxW;
        dh = boxH;
      } else {
        final sc = min(boxW / iw, boxH / ih);
        dw = iw * sc;
        dh = ih * sc;
      }
      canvas.drawImageRect(
        im,
        Rect.fromLTWH(0, 0, iw, ih),
        Rect.fromCenter(center: Offset(cx * s, cy * s), width: dw * s, height: dh * s),
        _imgPaint,
      );
    }

    // Búnkeres (sprite según vida: full → mid → broken).
    for (final c in state.bunkers) {
      final wall = c.hp >= 3
          ? sprites['wallFull']
          : c.hp == 2
          ? sprites['wallMid']
          : sprites['wallBroken'];
      img(wall, c.x, c.y, state.bunkerCell, state.bunkerCell, fill: true);
    }

    // Invasores (comandante = tanque; el resto anima entre soldado 1/2).
    final soldier = state.animFrame ? sprites['soldier2'] : sprites['soldier1'];
    final commander = sprites['commander'];
    for (final inv in state.invaders) {
      final im = inv.type == EnemyType.tank ? commander : soldier;
      img(im, inv.x, inv.y, kInvW + 8, kInvH + 10);
    }

    // Jefe (comandante grande) + barra de vida.
    final boss = state.boss;
    if (boss != null) {
      img(commander, boss.x, boss.y, 70, 46);
      final frac = (boss.hp / boss.maxHp).clamp(0.0, 1.0);
      final bg = Paint()..color = AppColors.backgroundDark;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(kFieldW / 2 * s, 14 * s), width: 120 * s, height: 6 * s),
          Radius.circular(2 * s),
        ),
        bg,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset((kFieldW / 2 - 60 * (1 - frac)) * s, 14 * s),
            width: 120 * frac * s,
            height: 6 * s,
          ),
          Radius.circular(2 * s),
        ),
        Paint()..color = AppColors.emerald,
      );
    }

    // OVNI (sin sprite propio: bloque amarillo).
    final ufo = state.ufo;
    if (ufo != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(ufo.x * s, 24 * s), width: 28 * s, height: 12 * s),
          Radius.circular(6 * s),
        ),
        Paint()..color = AppColors.yellow,
      );
    }

    // Power-ups (cápsula con letra).
    for (final p in state.powerups) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(p.x * s, p.y * s), width: 16 * s, height: 16 * s),
          Radius.circular(4 * s),
        ),
        Paint()..color = powerUpColor(p.type),
      );
      _text(canvas, powerUpGlyph(p.type), Offset(p.x * s, p.y * s), 10 * s, AppColors.backgroundDark);
    }

    // Balas (jugador: normal/crítica si hay mejora activa; enemigo: soldado o
    // comandante para las del jefe).
    final powered = state.rapidActive || state.tripleActive;
    final pBullet = powered ? sprites['pBulletCrit'] : sprites['pBullet'];
    for (final b in state.playerBullets) {
      img(pBullet, b.x, b.y, 9, 16);
    }
    final eStraight = sprites['eBullet1'];
    final eAimed = sprites['eBullet2'];
    final eBossBullet = sprites['cBullet'];
    for (final b in state.enemyBullets) {
      final im = boss != null ? eBossBullet : (b.vx != 0 ? eAimed : eStraight);
      img(im, b.x, b.y, 10, 16);
    }

    // Escudo de la nave.
    if (state.shieldActive) {
      canvas.drawCircle(
        Offset(state.shipX * s, kShipY * s),
        24 * s,
        Paint()
          ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * s,
      );
    }
    // Nave.
    img(sprites['player'], state.shipX, kShipY - 4, kShipW + 10, 34);
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
