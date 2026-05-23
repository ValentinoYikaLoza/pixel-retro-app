import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/shared/widgets/skeleton.dart';

/// Placeholder de la pantalla de juegos: título + carrusel (círculo grande).
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 24,
          children: [
            SkeletonBox(width: 220, height: 48, radius: 12),
            SkeletonCircle(size: 240),
          ],
        ),
      ),
    );
  }
}
