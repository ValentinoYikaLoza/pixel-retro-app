import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/providers/tetris_game_provider.dart';

/// Controles táctiles del Tetris (barra inferior). Botones grandes y separados
/// con etiqueta, agrupados en un panel para que sea cómodo de usar.
class TetrisControls extends ConsumerWidget {
  const TetrisControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tetrisGameProvider.notifier);
    final isPaused = ref.watch(tetrisGameProvider.select((s) => s.isPaused));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.neonPurple.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Acciones: rotar, hold, pausa.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Btn(
                icon: Icons.rotate_left,
                label: 'Girar',
                onTap: () => notifier.rotate(clockwise: false),
              ),
              _Btn(
                icon: Icons.rotate_right,
                label: 'Girar',
                onTap: () => notifier.rotate(),
              ),
              _Btn(icon: Icons.layers, label: 'Hold', onTap: notifier.hold),
              _Btn(
                icon: isPaused ? Icons.play_arrow : Icons.pause,
                label: isPaused ? 'Sigue' : 'Pausa',
                onTap: notifier.togglePause,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Movimiento: izquierda, bajar, caer, derecha.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Btn(
                icon: Icons.chevron_left,
                label: 'Izq',
                onTap: notifier.moveLeft,
              ),
              _Btn(
                icon: Icons.keyboard_arrow_down,
                label: 'Bajar',
                onTap: notifier.softDrop,
              ),
              _Btn(
                icon: Icons.vertical_align_bottom,
                label: 'Caer',
                onTap: notifier.hardDrop,
                accent: true,
              ),
              _Btn(
                icon: Icons.chevron_right,
                label: 'Der',
                onTap: notifier.moveRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  const _Btn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.accent
        ? AppColors.orange.withValues(alpha: 0.22)
        : AppColors.purple;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            width: 62,
            height: 56,
            decoration: BoxDecoration(
              color: _pressed
                  ? AppColors.neonPurple.withValues(alpha: 0.4)
                  : base,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.accent ? AppColors.orange : AppColors.neonPurple,
                width: 2,
              ),
              boxShadow: _pressed
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.neonPurple.withValues(alpha: 0.22),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(widget.icon, color: AppColors.white, size: 30),
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
