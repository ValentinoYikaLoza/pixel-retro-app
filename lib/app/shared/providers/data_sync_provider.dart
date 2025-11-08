import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pixel_retro_app/app/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/providers/mission_provider.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';
import 'package:pixel_retro_app/app/features/time/presentation/providers/time_provider.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';

enum SyncStatus { idle, syncing, success, error }

final dataSyncProvider = StateNotifierProvider<DataSyncNotifier, DataSyncState>(
  (ref) => DataSyncNotifier(ref),
);

class DataSyncNotifier extends StateNotifier<DataSyncState> {
  DataSyncNotifier(this.ref) : super(DataSyncState()) {
    _init();
  }

  final Ref ref;

  void _init() {
    ref.listen<bool>(
      internetStatusProvider.select((async) => async.value ?? false),
      (previous, hasInternet) {
        if (!hasInternet) {
          setSyncStatus(SyncStatus.idle);
        }
      },
    );
  }

  Future<void> sync() async {
    await Future.delayed(const Duration(seconds: 1), () {});

    final hasInternet = ref.read(internetStatusProvider).value ?? false;

    if (!hasInternet) return;

    setSyncStatus(SyncStatus.syncing);

    try {
      await Future.wait([
        ref.read(timeProvider.notifier).getTime(),
        ref.read(userProvider.notifier).getUser(),
        ref.read(leaderboardProvider.notifier).getUsers(),
        ref.read(leaderboardProvider.notifier).getDivisions(),
        ref.read(missionProvider.notifier).getMissions(),
        ref.read(shopProvider.notifier).getAdvertisements(),
        ref.read(shopProvider.notifier).getCoinShopItems(),
        ref.read(shopProvider.notifier).getLiveShopItems(),
      ]);
      setSyncStatus(SyncStatus.success);
    } catch (_) {
      setSyncStatus(SyncStatus.error);
      return;
    }

    print('🔥 Sync status: ${state.syncStatus}');
  }

  void setSyncStatus(SyncStatus syncStatus) {
    state = state.copyWith(syncStatus: syncStatus);
  }
}

class DataSyncState {
  final SyncStatus syncStatus;
  DataSyncState({this.syncStatus = SyncStatus.idle});

  DataSyncState copyWith({SyncStatus? syncStatus}) {
    return DataSyncState(syncStatus: syncStatus ?? this.syncStatus);
  }
}
