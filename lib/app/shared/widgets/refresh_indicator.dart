import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/providers/data_sync_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/loader.dart';

class RefreshIndicatorOverlay extends ConsumerWidget {
  final Widget child;
  const RefreshIndicatorOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double topPadding =
        kToolbarHeight + MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        child, // Tu contenido original debajo
        RefreshIndicator(
          color: AppColors.white,
          backgroundColor: AppColors.orange,
          displacement: topPadding + 10,
          onRefresh: () async {
            Loader.show();
            await ref.read(dataSyncProvider.notifier).sync();
            Loader.dissmiss();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Container(
              // Esto asegura que el scroll pueda existir aunque no haya contenido
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(top: topPadding),
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
