import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';

class GameControl extends ConsumerWidget {
  final Function(Direction) onDirectionChanged;
  final Function() onPauseChanged;
  final Function() onLostChanged;

  const GameControl({
    super.key,
    required this.onDirectionChanged,
    required this.onPauseChanged,
    required this.onLostChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(snakeGameProvider);

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.neonPurple, width: 2)),
      ),
      child: Center(
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.purple,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonPurple, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonPurple, width: 2),
                ),
              ),
              // Up button
              Positioned(
                top: 10,
                child: _ControlButton(
                  iconPath: 'assets/icons/arrow-up-2.svg',
                  onPressed: () => onDirectionChanged(Direction.up),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  direction: Direction.up,
                ),
              ),
              // Left button
              Positioned(
                left: 10,
                child: _ControlButton(
                  iconPath: 'assets/icons/arrow-left-2.svg',
                  onPressed: () => onDirectionChanged(Direction.left),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  direction: Direction.left,
                ),
              ),
              if (!gameState.hasLost)
                // Pause button
                Positioned(
                  child: _PauseButton(
                    isPaused: gameState.isPaused,
                    onPressed: () => onPauseChanged(),
                  ),
                ),
              if (gameState.hasLost)
                // Retry button
                Positioned(
                  child: _RetryButton(
                    hasLost: gameState.hasLost,
                    onPressed: () => onLostChanged(),
                  ),
                ),
              // Right button
              Positioned(
                right: 10,
                child: _ControlButton(
                  iconPath: 'assets/icons/arrow-right-2.svg',
                  onPressed: () => onDirectionChanged(Direction.right),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  direction: Direction.right,
                ),
              ),
              // Down button
              Positioned(
                bottom: 10,
                child: _ControlButton(
                  iconPath: 'assets/icons/arrow-down-2.svg',
                  onPressed: () => onDirectionChanged(Direction.down),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  direction: Direction.down,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final String iconPath;
  final VoidCallback onPressed;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Direction direction;

  const _ControlButton({
    required this.iconPath,
    required this.onPressed,
    required this.direction,
    this.shape = BoxShape.circle,
    this.borderRadius,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onPressed();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.neonPurple : AppColors.purple,
          shape: widget.shape,
          borderRadius: widget.borderRadius,
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: AppColors.orange.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
          border: Border.all(
            color: AppColors.neonPurple,
            width: _isPressed ? 3 : 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: widget.direction == Direction.right ? 10 : 6,
            right: widget.direction == Direction.left ? 10 : 6,
            top: widget.direction == Direction.down ? 10 : 6,
            bottom: widget.direction == Direction.up ? 10 : 6,
          ),
          child:
              widget.direction == Direction.up ||
                  widget.direction == Direction.down
              ? SvgPicture.asset(widget.iconPath, width: 12)
              : SvgPicture.asset(widget.iconPath, height: 12),
        ),
      ),
    );
  }
}

class _PauseButton extends StatefulWidget {
  final bool isPaused;
  final VoidCallback onPressed;

  const _PauseButton({required this.isPaused, required this.onPressed});

  @override
  State<_PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<_PauseButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 50,
        height: 50,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              widget.isPaused
                  ? 'assets/icons/play-2.svg' // Cambia a icono de play cuando está pausado
                  : 'assets/icons/pause.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.neonPurple,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatefulWidget {
  final bool hasLost;
  final VoidCallback onPressed;

  const _RetryButton({required this.hasLost, required this.onPressed});

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 50,
        height: 50,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              'assets/icons/retry.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.neonPurple,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
