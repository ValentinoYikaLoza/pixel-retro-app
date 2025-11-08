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
    final dataAsyncStatusState = ref.watch(dataSyncProvider);

    final hasConnection = internetStatusState.value ?? false;
    final hasDataAsync = dataAsyncStatusState.syncStatus == SyncStatus.success;

    return hasConnection && hasDataAsync
        ? RefreshIndicator(
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
            child: widget.child,
          )
        : Stack(
            children: [
              widget.child,
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
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          );
  }
}
