import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/shared/widgets/skeleton.dart';

/// Placeholder de misiones: recompensa mensual, semanal y retos diarios.
class MissionSkeleton extends StatelessWidget {
  const MissionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Shimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 30 + topPadding, 20, 30),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            // Mensual
            SkeletonBox(width: 180, height: 20),
            SkeletonBox(width: double.infinity, height: 100, radius: 15),
            // Semanal
            SkeletonBox(width: 220, height: 24),
            SkeletonBox(width: double.infinity, height: 120, radius: 15),
            // Diarias
            SkeletonBox(width: 160, height: 24),
            SkeletonBox(width: double.infinity, height: 120, radius: 15),
            SkeletonBox(width: double.infinity, height: 120, radius: 15),
            SkeletonBox(width: double.infinity, height: 120, radius: 15),
          ],
        ),
      ),
    );
  }
}
