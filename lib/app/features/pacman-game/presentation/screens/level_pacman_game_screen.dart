import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/logic/pacman_maze.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/providers/pacman_levels_provider.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/widgets/pacman_starting_loader.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_icon_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/screen_status.dart';

/// Selector de niveles de Pac-Man (carrusel 3D). La miniatura muestra el
/// laberinto; la dificultad sube con la velocidad por nivel.
class LevelPacmanGameScreen extends ConsumerStatefulWidget {
  const LevelPacmanGameScreen({super.key});

  @override
  ConsumerState<LevelPacmanGameScreen> createState() =>
      _LevelPacmanGameScreenState();
}

class _LevelPacmanGameScreenState extends ConsumerState<LevelPacmanGameScreen> {
  final _controller = PageController(viewportFraction: 0.72);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    setScreenConfig();
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
    final levels = ref.watch(pacmanLevelsProvider);
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
                loading: () => const PacmanStartingLoader(
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
                          onPlay: () => AppRoutes.go(
                            AppRoutes.pacmanGame,
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
  final VoidCallback onPlay;
  final VoidCallback onTapCard;

  const _LevelCard({
    required this.level,
    required this.focused,
    required this.width,
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
                            height: previewWidth * 29 / 28,
                            child: CustomPaint(
                              painter: _PacmanPreviewPainter(),
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
                          label: 'Puntos ${level.targetScore}',
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

/// Miniatura del laberinto de Pac-Man (paredes + Pac en su spawn).
class _PacmanPreviewPainter extends CustomPainter {
  static final PacmanMaze _maze = PacmanMaze(kPacmanMazeL1);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.backgroundDark,
    );
    final s = size.width / _maze.width;
    final wall = Paint()..color = const Color(0xFF3B3BCF);
    final pellet = Paint()..color = const Color(0xFFFFE08A);

    for (var y = 0; y < _maze.height; y++) {
      final row = _maze.rows[y];
      for (var x = 0; x < _maze.width; x++) {
        final c = row[x];
        if (c == '#') {
          canvas.drawRect(
            Rect.fromLTWH(x * s, y * s, s, s).deflate(s * 0.12),
            wall,
          );
        } else if (c == '.' || c == 'o') {
          canvas.drawCircle(
            Offset((x + 0.5) * s, (y + 0.5) * s),
            c == 'o' ? s * 0.28 : s * 0.12,
            pellet,
          );
        }
      }
    }

    // Pac en su spawn.
    canvas.drawCircle(
      Offset((_maze.pacSpawn.x + 0.5) * s, (_maze.pacSpawn.y + 0.5) * s),
      s * 0.5,
      Paint()..color = AppColors.yellow,
    );
  }

  @override
  bool shouldRepaint(_PacmanPreviewPainter oldDelegate) => false;
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
