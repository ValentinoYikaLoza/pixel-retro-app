import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

/// Sistema de skeleton loaders con efecto shimmer, adaptado a la paleta de la
/// app (base gris sobre fondo oscuro, con un barrido tintado de naranja).
///
/// Uso: envolver el layout de placeholders en [Shimmer] y componerlo con
/// [SkeletonBox] / [SkeletonCircle]. Un solo `AnimationController` anima todo el
/// subárbol (eficiente y con barrido cohesivo).
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  static const Color base = AppColors.gray;
  static final Color highlight = Color.lerp(
    AppColors.gray,
    AppColors.orange,
    0.30,
  )!;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Shimmer.base, Shimmer.highlight, Shimmer.base],
              stops: [
                (v - 0.3).clamp(0.0, 1.0),
                v.clamp(0.0, 1.0),
                (v + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Bloque rectangular opaco (lo "pinta" el [Shimmer] padre).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Shimmer.base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Círculo opaco (avatares, trofeos, items circulares).
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Shimmer.base,
        shape: BoxShape.circle,
      ),
    );
  }
}
