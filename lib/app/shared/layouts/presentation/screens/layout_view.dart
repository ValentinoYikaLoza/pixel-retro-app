import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/widgets/tabs_layout.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_appbar.dart';
import 'package:pixel_retro_app/app/shared/widgets/refresh_indicator.dart';

class LayoutView extends StatefulWidget {
  final Widget child;

  const LayoutView({super.key, required this.child});

  @override
  State<LayoutView> createState() => _LayoutViewState();
}

class _LayoutViewState extends State<LayoutView> {
  @override
  Widget build(BuildContext context) {
    final String route = Get.currentRoute;

    return Scaffold(
      appBar: route == AppRoutes.leaderboard || route == AppRoutes.mission
          ? null
          : CustomAppbar(),
      bottomNavigationBar: const TabsLayout(),
      body: RefreshIndicatorOverlay(child: widget.child),
    );
  }
}
