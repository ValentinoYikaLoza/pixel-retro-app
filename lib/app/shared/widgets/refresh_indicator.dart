import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/providers/data_sync_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/loader.dart';
import 'package:pixel_retro_app/app/shared/widgets/no_internet_dialog.dart';

class RefreshIndicatorOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const RefreshIndicatorOverlay({super.key, required this.child});

  @override
  RefreshIndicatorOverlayState createState() => RefreshIndicatorOverlayState();
}

class RefreshIndicatorOverlayState
    extends ConsumerState<RefreshIndicatorOverlay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showNoInternetDialog() {
    if (Get.isDialogOpen == true) return;
    Get.dialog(const NoInternetDialog(), barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        kToolbarHeight + MediaQuery.of(context).padding.top;

    final internetStatusState = ref.watch(internetStatusProvider);

    final hasConnection = internetStatusState.value ?? false;

    return Stack(
      children: [
        widget.child, // Tu contenido original debajo
        RefreshIndicator(
          color: AppColors.white,
          backgroundColor: AppColors.orange,
          displacement: topPadding + 10,
          onRefresh: () async {
            if (!hasConnection) {
              _showNoInternetDialog();
              return;
            }

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
