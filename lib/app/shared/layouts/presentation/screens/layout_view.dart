import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/widgets/tabs_layout.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';
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
  void initState() {
    super.initState();
    // El layout es portrait. Al volver del juego (landscape) esto restaura la
    // orientación; el fade de la ruta enmascara la rotación.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrientationService.setPortrait();
      OrientationService.setEdgeToEdge();
      OrientationService.setOverlayColor(AppColors.orange);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String route = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: route == AppRoutes.leaderboard || route == AppRoutes.mission
          ? null
          : CustomAppbar(),
      bottomNavigationBar: const TabsLayout(),
      body: RefreshIndicatorOverlay(child: widget.child),
    );
  }
}
