import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'dart:ui' as ui;

import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_defs.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_sprites.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/providers/invaders_levels_provider.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/widgets/invaders_starting_loader.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_icon_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/infinite_mode_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/screen_status.dart';

/// Selector de niveles de Pixel Invaders (carrusel 3D). La miniatura muestra la
/// formación y los búnkeres del nivel, reflejando su dificultad.
class LevelInvadersGameScreen extends ConsumerStatefulWidget {
  const LevelInvadersGameScreen({super.key});

  @override
  ConsumerState<LevelInvadersGameScreen> createState() =>
      _LevelInvadersGameScreenState();
}

class _LevelInvadersGameScreenState
    extends ConsumerState<LevelInvadersGameScreen> {
  final _controller = PageController(viewportFraction: 0.72);
  int _current = 0;
  InvadersSprites? _sprites;

  @override
  void initState() {
    super.initState();
    setScreenConfig();
    InvadersSprites.load().then((s) {
      if (mounted) setState(() => _sprites = s);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setScreenConfig() {
    OrientationService.setOverlayColor(AppColors.neonPurple);
    OrientationService.setPortrait();
    OrientationService.setImmersiveMode();
  }

  @override
  Widget build(BuildContext context) {
    final levels = ref.watch(invadersLevelsProvider);
    final size = MediaQuery.of(context).size;
    final cardWidth = (size.width * 0.62).clamp(200.0, 300.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: setScreenConfig,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Stack(
            children: [
              levels.when(
                loading: () => const InvadersStartingLoader(
                  title: 'CARGANDO',
                  subtitle: 'Cargando niveles',
                ),
                error: (_, __) => const ScreenError(
                  message: 'No se pudieron cargar los niveles',
                ),
                data: (list) => PageView.builder(
                  controller: _controller,
                  itemCount: list.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, i) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        var delta = (i - _current).toDouble();
                        if (_controller.hasClients &&
                            _controller.position.hasContentDimensions) {
                          delta = i - (_controller.page ?? _current.toDouble());
                        }
                        final rotationY = delta.clamp(-1.0, 1.0) * -0.55;
                        final scale = (1 - delta.abs() * 0.22).clamp(0.78, 1.0);
                        final opacity = (1 - delta.abs() * 0.45).clamp(0.45, 1.0);
                        final matrix = Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(rotationY)
                          ..scale(scale);
                        return Opacity(
                          opacity: opacity,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: matrix,
                            child: child,
                          ),
                        );
                      },
                      child: Center(
                        child: _LevelCard(
                          level: list[i],
                          focused: i == _current,
                          width: cardWidth,
                          sprites: _sprites,
                          onPlay: () => AppRoutes.go(
                            AppRoutes.invadersGame,
                            arguments: {'level': list[i].level},
                          ),
                          onTapCard: () {
                            if (i != _current) {
                              _controller.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 4,
                left: 8,
                child: CustomIconButton(
                  onPressed: () => AppRoutes.go(AppRoutes.home),
                  width: 48,
                  height: 48,
                  imagePath: 'assets/icons/back.svg',
                ),
              ),
              Positioned(
                top: 10,
                right: 12,
                child: InfiniteModeButton(
                  onTap: () => AppRoutes.go(
                    AppRoutes.invadersGame,
                    arguments: {'level': 0},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GameLevelEntity level;
  final bool focused;
  final double width;
  final InvadersSprites? sprites;
  final VoidCallback onPlay;
  final VoidCallback onTapCard;

  const _LevelCard({
    required this.level,
    required this.focused,
    required this.width,
    required this.sprites,
    required this.onPlay,
    required this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !level.unlocked;
    final previewWidth = width - 28;

    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.purple, AppColors.backgroundDark],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: focused
                ? AppColors.neonPurple
                : AppColors.neonPurple.withValues(alpha: 0.35),
            width: focused ? 4 : 2,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: AppColors.neonPurple.withValues(alpha: 0.5),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.5),
                border: const Border(
                  bottom: BorderSide(color: AppColors.neonPurple, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Title('NIVEL ${level.level}', fontSize: focused ? 22 : 18),
                  if (level.cleared)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.emerald,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.neonPurple.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: locked ? 0.4 : 1,
                          child: SizedBox(
                            width: previewWidth,
                            height: previewWidth * 0.9,
                            child: CustomPaint(
                              painter: _InvadersPreviewPainter(level, sprites),
                            ),
                          ),
                        ),
                        if (locked)
                          Positioned.fill(
                            child: Center(
                              child: Icon(
                                Icons.lock,
                                color: AppColors.white.withValues(alpha: 0.9),
                                size: 38,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Chip(
                          label: 'Meta ${level.targetScore}',
                          color: AppColors.purple,
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          label: 'Mejor ${level.bestScore}',
                          color: level.bestScore > 0
                              ? AppColors.orange
                              : AppColors.gray,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: focused
                        ? (locked
                              ? Center(
                                  child: Text(
                                    'BLOQUEADO',
                                    style: TextStyle(
                                      color: AppColors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Pixel',
                                    ),
                                  ),
                                )
                              : CustomTextButton(
                                  width: 140,
                                  height: 44,
                                  radius: 12,
                                  label: 'JUGAR',
                                  onPressed: onPlay,
                                ))
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Miniatura: formación de invasores (filas/columnas según el nivel) y búnkeres
/// del nivel, para reflejar la dificultad.
class _InvadersPreviewPainter extends CustomPainter {
  _InvadersPreviewPainter(this.level, this.sprites);

  final GameLevelEntity level;
  final InvadersSprites? sprites;

  void _img(Canvas canvas, ui.Image? im, Rect dst, {bool fill = false}) {
    if (im == null) return;
    final iw = im.width.toDouble();
    final ih = im.height.toDouble();
    Rect out = dst;
    if (!fill) {
      final sc = (dst.width / iw) < (dst.height / ih)
          ? dst.width / iw
          : dst.height / ih;
      out = Rect.fromCenter(center: dst.center, width: iw * sc, height: ih * sc);
    }
    canvas.drawImageRect(
      im,
      Rect.fromLTWH(0, 0, iw, ih),
      out,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.backgroundDark;
    canvas.drawRect(Offset.zero & size, paint);

    final plan = LevelPlan.forLevel(level.level);
    final cellW = size.width / (plan.cols + 1);
    final invSize = cellW * 0.7;
    final startX = cellW;
    final startY = size.height * 0.12;
    final soldier = sprites?['soldier1'];
    final commander = sprites?['commander'];

    for (var r = 0; r < plan.rows; r++) {
      final isTank = plan.typeForRow(r, level.level) == EnemyType.tank;
      for (var c = 0; c < plan.cols; c++) {
        final cx = startX + c * cellW;
        final cy = startY + r * (invSize + 4);
        final dst = Rect.fromCenter(center: Offset(cx, cy), width: invSize, height: invSize);
        if (sprites != null) {
          _img(canvas, isTank ? commander : soldier, dst);
        } else {
          paint.color = enemyColor(plan.typeForRow(r, level.level));
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(cx, cy), width: invSize, height: invSize * 0.8),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }

    // Búnkeres.
    final gw = level.gridWidth == 0 ? 24 : level.gridWidth;
    final gh = level.gridHeight == 0 ? 24 : level.gridHeight;
    final bw = size.width / gw;
    final wall = sprites?['wallFull'];
    for (final c in level.walls) {
      final rect = Rect.fromLTWH(c.dx / gw * size.width, c.dy / gh * size.height, bw, bw);
      if (sprites != null) {
        _img(canvas, wall, rect, fill: true);
      } else {
        canvas.drawRect(rect, paint..color = AppColors.emerald.withValues(alpha: 0.8));
      }
    }

    // Nave.
    final shipRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 12),
      width: cellW * 1.2,
      height: cellW * 1.2,
    );
    if (sprites != null) {
      _img(canvas, sprites!['player'], shipRect);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: shipRect.center, width: cellW, height: 6),
          const Radius.circular(2),
        ),
        paint..color = AppColors.neonPurple,
      );
    }
  }

  @override
  bool shouldRepaint(_InvadersPreviewPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.sprites != sprites;
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  final double fontSize;

  const _Title(this.text, {this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pixel',
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = AppColors.neonPurple,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: AppColors.purple,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pixel',
          ),
        ),
      ],
    );
  }
}
