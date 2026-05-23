import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/widgets/skeleton.dart';

/// Placeholder del leaderboard: cabecera (división + tiempo), fila de trofeos y
/// filas de usuarios.
class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Container(
            padding: EdgeInsets.only(top: 30 + topPadding, bottom: 30),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gray, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 30,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 140, height: 24),
                      SkeletonBox(width: 90, height: 20),
                    ],
                  ),
                ),
                SizedBox(
                  height: 75,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(width: 20),
                    itemBuilder: (_, __) => const SkeletonCircle(size: 75),
                  ),
                ),
              ],
            ),
          ),
          // Filas de usuarios
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 15),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SkeletonCircle(size: 45),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            SkeletonBox(width: 120, height: 16),
                            SkeletonBox(width: 60, height: 12),
                          ],
                        ),
                      ],
                    ),
                    SkeletonBox(width: 60, height: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
