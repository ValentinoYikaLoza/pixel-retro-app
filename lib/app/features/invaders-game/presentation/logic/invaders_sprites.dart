import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Cache de sprites de Pixel Invaders rasterizados de SVG a `ui.Image`, para
/// poder dibujarlos en el `CustomPaint` del tablero (el canvas no dibuja SVG
/// directamente). Se carga una sola vez por sesión.
///
class InvadersSprites {
  InvadersSprites._(this._images);

  final Map<String, ui.Image> _images;

  ui.Image? operator [](String key) => _images[key];

  static InvadersSprites? _instance;

  static const String _base = 'assets/icons/games/invaders';
  static const Map<String, String> _assets = {
    'player': '$_base/player/player.svg',
    'pBullet': '$_base/player/normal_player_projectile.svg',
    'pBulletCrit': '$_base/player/critical_player_projectile.svg',
    'soldier1': '$_base/enemy/enemy_soldier_1.svg',
    'soldier2': '$_base/enemy/enemy_soldier_2.svg',
    'eBullet1': '$_base/enemy/enemy_soldier_projectile_1.svg',
    'eBullet2': '$_base/enemy/enemy_soldier_projectile_2.svg',
    'commander': '$_base/enemy/enemy_commander.svg',
    'cBullet': '$_base/enemy/enemy_commander_projectile.svg',
    'wallFull': '$_base/wall/full_wall.svg',
    'wallMid': '$_base/wall/middle_wall.svg',
    'wallBroken': '$_base/wall/broken_wall.svg',
  };

  /// Carga (o devuelve cacheado) todos los sprites.
  static Future<InvadersSprites> load() async {
    final cached = _instance;
    if (cached != null) return cached;

    final map = <String, ui.Image>{};
    for (final entry in _assets.entries) {
      map[entry.key] = await _rasterize(entry.value, 160);
    }
    final sprites = InvadersSprites._(map);
    _instance = sprites;
    return sprites;
  }

  /// Rasteriza un SVG a `ui.Image` escalando a [maxSide] px en su lado mayor.
  static Future<ui.Image> _rasterize(String asset, double maxSide) async {
    final info = await vg.loadPicture(SvgAssetLoader(asset), null);
    final w0 = info.size.width;
    final h0 = info.size.height;
    final scale = maxSide / (w0 > h0 ? w0 : h0);
    final tw = (w0 * scale).round().clamp(1, 4096);
    final th = (h0 * scale).round().clamp(1, 4096);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(scale);
    canvas.drawPicture(info.picture);
    final pic = recorder.endRecording();
    final image = await pic.toImage(tw, th);

    info.picture.dispose();
    pic.dispose();
    return image;
  }
}
