import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/shared/widgets/skeleton.dart';

/// Placeholder de la tienda: anuncios + grillas de monedas y vidas.
class ShopSkeleton extends StatelessWidget {
  const ShopSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anuncios
            SkeletonBox(width: 120, height: 24),
            SizedBox(height: 20),
            SkeletonBox(width: double.infinity, height: 72, radius: 15),
            SizedBox(height: 12),
            SkeletonBox(width: double.infinity, height: 72, radius: 15),
            SizedBox(height: 30),
            // Monedas
            SkeletonBox(width: 120, height: 24),
            SizedBox(height: 20),
            _GridRow(),
            SizedBox(height: 20),
            _GridRow(),
            SizedBox(height: 30),
            // Vidas
            SkeletonBox(width: 120, height: 24),
            SizedBox(height: 20),
            _GridRow(),
          ],
        ),
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: SkeletonBox(height: 150, radius: 15)),
        SizedBox(width: 20),
        Expanded(child: SkeletonBox(height: 150, radius: 15)),
      ],
    );
  }
}
