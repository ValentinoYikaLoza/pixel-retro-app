import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/features/time/presentation/providers/time_provider.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/features/home/presentation/providers/home_provider.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/providers/mission_provider.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';

enum SyncStatus { idle, syncing, success, error }

class DataSyncNotifier extends Notifier<void> {
  final StreamController<SyncStatus> _syncController =
      StreamController<SyncStatus>.broadcast();
  bool _isSyncing = false;

  Stream<SyncStatus> get syncStatusStream => _syncController.stream;

  @override
  void build() {
    // 🔥 Escuchar cambios de internet
    ref.listen<bool>(
      internetStatusProvider.select((async) => async.value ?? false),
      (previous, hasInternet) {
        if (!hasInternet) {
          _isSyncing = false;
          _syncController.add(
            SyncStatus.idle,
          ); // ❗ Cambia el estado de sync a idle
        }
      },
    );

    // ✅ Liberar recursos cuando el provider se destruya
    ref.onDispose(() {
      _syncController.close();
    });
  }

  Future<bool> sync() async {
    final hasInternet = ref.read(internetStatusProvider).value ?? false;
    if (!hasInternet) return false;

    if (_isSyncing) return false;

    _isSyncing = true;
    _syncController.add(SyncStatus.syncing); // ⬆️ Comienza sync

    try {
      await Future.wait([
        ref.read(timeProvider.notifier).getTime(),
        ref.read(userProvider.notifier).getUser(),
        ref.read(homeProvider.notifier).getGames(),
        ref.read(leaderboardProvider.notifier).getUsers(),
        ref.read(leaderboardProvider.notifier).getDivisions(),
        ref.read(missionProvider.notifier).getMissions(),
        ref.read(shopProvider.notifier).getAdvertisements(),
        ref.read(shopProvider.notifier).getCoinShopItems(),
        ref.read(shopProvider.notifier).getLiveShopItems(),
      ]);

      _syncController.add(SyncStatus.success); // ⬇️ Termina sync
      return true;
    } catch (_) {
      _syncController.add(SyncStatus.error); // ⬇️ Termina sync
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}

final dataSyncProvider = NotifierProvider<DataSyncNotifier, void>(
  () => DataSyncNotifier(),
);

final dataSyncStatusProvider = StreamProvider<SyncStatus>(
  (ref) => ref.read(dataSyncProvider.notifier).syncStatusStream,
);
