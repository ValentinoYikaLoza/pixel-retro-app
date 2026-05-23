import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/providers/tetris_game_provider.dart';

/// Controles táctiles del Tetris: mover, rotar, soft/hard drop, hold y pausa.
class TetrisControls extends ConsumerWidget {
  const TetrisControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tetrisGameProvider.notifier);
    final isPaused = ref.watch(tetrisGameProvider.select((s) => s.isPaused));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Btn(
              icon: Icons.rotate_left,
              onTap: () => notifier.rotate(clockwise: false),
            ),
            const SizedBox(width: 10),
            _Btn(icon: Icons.rotate_right, onTap: () => notifier.rotate()),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Btn(icon: Icons.chevron_left, onTap: notifier.moveLeft),
            const SizedBox(width: 10),
            _Btn(icon: Icons.keyboard_arrow_down, onTap: notifier.softDrop),
            const SizedBox(width: 10),
            _Btn(icon: Icons.chevron_right, onTap: notifier.moveRight),
          ],
        ),
        const SizedBox(height: 10),
        _Btn(
          icon: Icons.vertical_align_bottom,
          onTap: notifier.hardDrop,
          wide: true,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Btn(icon: Icons.swap_vert, onTap: notifier.hold),
            const SizedBox(width: 10),
            _Btn(
              icon: isPaused ? Icons.play_arrow : Icons.pause,
              onTap: notifier.togglePause,
            ),
          ],
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool wide;

  const _Btn({required this.icon, required this.onTap, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: wide ? 132 : 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.purple,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neonPurple, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPurple.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.white, size: 26),
      ),
    );
  }
}
