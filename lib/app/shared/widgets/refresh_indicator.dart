import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/home/domain/repositories/home_repository.dart';
import 'package:pixel_retro_app/app/features/home/presentation/providers/home_provider.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/providers/mission_provider.dart';
import 'package:pixel_retro_app/app/features/shop/domain/repositories/shop_repository.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';
import 'package:pixel_retro_app/app/features/time/presentation/providers/time_provider.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/services/dialog_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/no_internet_dialog.dart';
import 'package:pixel_retro_app/di.dart';
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
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _showNoInternetDialog() {
    DialogService.show(const NoInternetDialog(), barrierDismissible: false);
  }

  /// Limpia las cachés de los repositorios y vuelve a ejecutar la carga de
  /// cada pantalla (cada init provider se re-ejecuta y trae datos frescos).
  void _reloadAll() {
    getIt<HomeRepository>().clearCache();
    getIt<LeaderboardRepository>().clearCache();
    getIt<ShopRepository>().clearCache();

    ref.invalidate(userInitProvider);
    ref.invalidate(timeInitProvider);
    ref.invalidate(homeInitProvider);
    ref.invalidate(leaderboardInitProvider);
    ref.invalidate(missionInitProvider);
    ref.invalidate(shopInitProvider);
  }

  @override
  Widget build(BuildContext context) {
    final internetStatusState = ref.watch(internetStatusProvider);
    final hasConnection = internetStatusState.value ?? false;

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () async {
        if (!hasConnection) {
          _refreshController.refreshFailed();
          _showNoInternetDialog();
          return;
        }

        _reloadAll();
        _refreshController.refreshCompleted();
      },
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
