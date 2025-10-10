import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_mission_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/repositories/mission_repository.dart';
import 'package:pixel_retro_app/app/features/mission/presentation/data/mission_mapper.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/providers/web_socket_provider.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final missionProvider = StateNotifierProvider<MissionNotifier, MissionState>((
  ref,
) {
  return MissionNotifier(ref);
});

class MissionNotifier extends StateNotifier<MissionState> {
  MissionNotifier(this.ref) : super(const MissionState());

  final Ref ref;
  final MissionRepository repository = getIt<MissionRepository>();

  StreamSubscription<Map<String, dynamic>>? _missionsSub;

  /// Inicializa las misiones y se suscribe a los streams del WebSocket
  Future<void> initData() async {
    // Obtiene la instancia del socket desde Riverpod
    final socket = ref.read(websocketServiceProvider);
    // 🎯 Escucha las misiones en tiempo real
    _missionsSub = socket.missionsStream.listen((missions) {
      // print('🎯 [MissionNotifier] Misiones recibidas: $missions');

      final GetMissionListResponseModel model = MissionMapper.fromSocketData(
        missions,
      );
      state = state.copyWith(
        dailyRewards: model.dailyRewards,
        weeklyReward: model.weeklyReward,
        monthlyReward: model.monthlyReward,
      );
    });
  }

  Future<void> getMissions() async {
    try {
      await initData();
      await repository.getMissions();
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo la lista de misiones',
        type: SnackbarType.error,
      );
    }
  }

  String getRewardImage(RewardCategory category) {
    switch (category) {
      case RewardCategory.bronzeChest:
        return 'assets/icons/bronze-chest.svg';
      case RewardCategory.silverChest:
        return 'assets/icons/silver-chest.svg';
      case RewardCategory.goldChest:
        return 'assets/icons/gold-chest.svg';
    }
  }

  @override
  void dispose() {
    _missionsSub?.cancel();
    super.dispose();
  }
}

class MissionState {
  final MissionEntity? monthlyReward;
  final MissionEntity? weeklyReward;
  final List<MissionEntity> dailyRewards;

  const MissionState({
    this.monthlyReward,
    this.weeklyReward,
    this.dailyRewards = const [],
  });

  MissionState copyWith({
    MissionEntity? monthlyReward,
    MissionEntity? weeklyReward,
    List<MissionEntity>? dailyRewards,
  }) {
    return MissionState(
      monthlyReward: monthlyReward ?? this.monthlyReward,
      weeklyReward: weeklyReward ?? this.weeklyReward,
      dailyRewards: dailyRewards ?? this.dailyRewards,
    );
  }
}
