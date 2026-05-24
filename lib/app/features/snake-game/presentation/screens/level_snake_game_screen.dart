import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_levels_provider.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/level_preview.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/widgets/starting_loader.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_icon_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';
import 'package:pixel_retro_app/app/shared/widgets/screen_status.dart';

/// Selector de niveles del Snake en carrusel 3D (estilo coverflow): la carta
/// central se ve grande y resaltada, y las laterales se inclinan en perspectiva.
/// Cada carta muestra una miniatura que refleja la complejidad del nivel.
class LevelSnakeGameScreen extends ConsumerStatefulWidget {
  const LevelSnakeGameScreen({super.key});

  @override
  ConsumerState<LevelSnakeGameScreen> createState() =>
      _LevelSnakeGameScreenState();
}

class _LevelSnakeGameScreenState extends ConsumerState<LevelSnakeGameScreen> {
  final _controller = PageController(viewportFraction: 0.5);
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
    OrientationService.setLandscape();
    OrientationService.setImmersiveMode();
  }

  @override
  Widget build(BuildContext context) {
    final levels = ref.watch(snakeLevelsProvider);
    final size = MediaQuery.of(context).size;
    final cardWidth = (size.width * 0.42).clamp(220.0, 300.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: setScreenConfig,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Stack(
            children: [
              levels.when(
                loading: () => const StartingLoader(
                  title: 'CARGANDO',
                  subtitle: 'Cargando niveles',
                ),
                error: (_, __) => const ScreenError(
                  message: 'No se pudieron cargar los niveles',
                ),
                data: (list) => _Carousel(
                  controller: _controller,
                  levels: list,
                  current: _current,
                  cardWidth: cardWidth,
                  onPageChanged: (i) => setState(() => _current = i),
                  onSelect: (i) => _controller.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              // El botón va al final del Stack para quedar por encima del
              // carrusel y poder recibir los toques.
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

class _Carousel extends StatelessWidget {
  final PageController controller;
  final List<GameLevelEntity> levels;
  final int current;
  final double cardWidth;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSelect;

  const _Carousel({
    required this.controller,
    required this.levels,
    required this.current,
    required this.cardWidth,
    required this.onPageChanged,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: levels.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // Distancia (continua) de esta carta al centro del carrusel.
            var delta = (i - current).toDouble();
            if (controller.hasClients &&
                controller.position.hasContentDimensions) {
              delta = i - (controller.page ?? current.toDouble());
            }

            final rotationY = delta.clamp(-1.0, 1.0) * -0.55;
            final scale = (1 - delta.abs() * 0.22).clamp(0.78, 1.0);
            final opacity = (1 - delta.abs() * 0.45).clamp(0.45, 1.0);

            final matrix = Matrix4.identity()
              ..setEntry(3, 2, 0.0012) // perspectiva
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
              level: levels[i],
              focused: i == current,
              width: cardWidth,
              onPlay: () => AppRoutes.go(
                AppRoutes.snakeGame,
                arguments: {'level': levels[i].level},
              ),
              onTapCard: () {
                if (i != current) onSelect(i);
              },
            ),
          ),
        );
      },
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
            // Barra de título.
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
                  // Miniatura del tablero (refleja la complejidad) + candado.
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
                          child: LevelPreview(
                            level: level,
                            width: previewWidth,
                            height: previewWidth * 0.55,
                          ),
                        ),
                        // Serpiente decorativa sobre la miniatura.
                        Positioned.fill(
                          child: Opacity(
                            opacity: locked ? 0.4 : 1,
                            child: Align(
                              alignment: const Alignment(0, 0.5),
                              child: _PreviewSnake(seg: previewWidth * 0.12),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 12),
                  // El botón solo aparece en la carta central.
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

/// Serpiente decorativa (cola → cuerpo → cabeza) para la miniatura del selector,
/// usando los mismos sprites del juego. Mira hacia la derecha.
class _PreviewSnake extends StatelessWidget {
  final double seg;

  const _PreviewSnake({required this.seg});

  Widget _part(String asset, {int quarterTurns = 0}) {
    return SizedBox(
      width: seg,
      height: seg,
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: SvgPicture.asset(asset, fit: BoxFit.fill),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cola a la izquierda, apuntando hacia afuera (giro 180°).
        _part('assets/icons/games/snake/snake_tail.svg', quarterTurns: 2),
        _part('assets/icons/games/snake/snake_body.svg'),
        _part('assets/icons/games/snake/snake_body.svg'),
        _part('assets/icons/games/snake/snake_head_right.svg'),
      ],
    );
  }
}
