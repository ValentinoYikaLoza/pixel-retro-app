import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/providers/data_sync_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/loader.dart';
import 'package:pixel_retro_app/app/shared/widgets/no_internet_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshIndicatorOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const RefreshIndicatorOverlay({super.key, required this.child});

  @override
  RefreshIndicatorOverlayState createState() => RefreshIndicatorOverlayState();
}

class RefreshIndicatorOverlayState
    extends ConsumerState<RefreshIndicatorOverlay> {
  final RefreshController _refreshController = RefreshController();

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
    final internetStatusState = ref.watch(internetStatusProvider);
    final dataAsyncStatusState = ref.watch(dataSyncProvider);

    final hasConnection = internetStatusState.value ?? false;
    final hasDataAsync = dataAsyncStatusState.syncStatus == SyncStatus.success;

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () async {
        if (!hasConnection) {
          _refreshController.refreshFailed();
          _showNoInternetDialog();
          return;
        }

        _refreshController.refreshCompleted();
        Loader.show();
        await ref.read(dataSyncProvider.notifier).sync();
        Loader.dissmiss();
      },
      enablePullDown: !hasConnection || !hasDataAsync,
      header: CustomHeader(
        height: 60,
        builder: (context, status) {
          return Container(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.white,
                ),
              ),
            ),
          );
        },
      ),

      child: widget.child,
    );
  }
}
