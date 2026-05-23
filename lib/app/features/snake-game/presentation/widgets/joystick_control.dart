import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';

/// Joystick analógico para el Snake: la dirección se actualiza de forma continua
/// mientras se arrastra el dedo, así el movimiento es más fluido que con botones.
/// Encima va un botón de pausa (o reintentar si se perdió).
class JoystickControl extends ConsumerStatefulWidget {
  final void Function(Direction) onDirectionChanged;
  final VoidCallback onPauseChanged;
  final VoidCallback onLostChanged;

  const JoystickControl({
    super.key,
    required this.onDirectionChanged,
    required this.onPauseChanged,
    required this.onLostChanged,
  });

  @override
  ConsumerState<JoystickControl> createState() => _JoystickControlState();
}

class _JoystickControlState extends ConsumerState<JoystickControl> {
  static const double _base = 132;
  static const double _knob = 56;
  static const double _maxRadius = (_base - _knob) / 2;
  static const double _deadZone = 10;

  Offset _knobPos = Offset.zero;

  void _handle(Offset local) {
    const center = Offset(_base / 2, _base / 2);
    var v = local - center;
    if (v.distance > _maxRadius) {
      v = Offset.fromDirection(v.direction, _maxRadius);
    }
    setState(() => _knobPos = v);

    if (v.distance >= _deadZone) {
      final dir = v.dx.abs() > v.dy.abs()
          ? (v.dx > 0 ? Direction.right : Direction.left)
          : (v.dy > 0 ? Direction.down : Direction.up);
      widget.onDirectionChanged(dir);
    }
  }

  void _reset() => setState(() => _knobPos = Offset.zero);

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(snakeGameProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          hasLost: gameState.hasLost,
          isPaused: gameState.isPaused,
          onPause: widget.onPauseChanged,
          onRetry: widget.onLostChanged,
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onPanStart: (d) => _handle(d.localPosition),
          onPanUpdate: (d) => _handle(d.localPosition),
          onPanEnd: (_) => _reset(),
          onPanCancel: _reset,
          child: Container(
            width: _base,
            height: _base,
            decoration: BoxDecoration(
              color: AppColors.purple,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonPurple, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: _knobPos,
                  child: Container(
                    width: _knob,
                    height: _knob,
                    decoration: BoxDecoration(
                      color: AppColors.neonPurple.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPurple.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool hasLost;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onRetry;

  const _ActionButton({
    required this.hasLost,
    required this.isPaused,
    required this.onPause,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final icon = hasLost
        ? 'assets/icons/retry.svg'
        : (isPaused ? 'assets/icons/play-2.svg' : 'assets/icons/pause.svg');

    return GestureDetector(
      onTap: hasLost ? onRetry : onPause,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.purple,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.neonPurple, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: SvgPicture.asset(
            icon,
            colorFilter: const ColorFilter.mode(
              AppColors.neonPurple,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
