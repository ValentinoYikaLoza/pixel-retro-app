import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/widgets/tabs_layout.dart';
import 'package:pixel_retro_app/app/shared/widgets/refresh_indicator.dart';

class LayoutView extends StatelessWidget {
  final Widget child;

  const LayoutView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const TabsLayout(),
      body: RefreshIndicatorOverlay(child: child),
    );
  }
}
