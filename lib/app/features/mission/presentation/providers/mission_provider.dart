import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/repositories/mission_repository.dart';
import 'package:pixel_retro_app/app/features/mission/data/mappers/mission_mapper.dart';
import 'package:pixel_retro_app/app/features/time/presentation/providers/time_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/web_socket_provider.dart';
import 'package:pixel_retro_app/di.dart';

final missionProvider = StateNotifierProvider<MissionNotifier, MissionState>((
  ref,
) {
  return MissionNotifier(ref);
});

/// Carga los datos de la pantalla de misiones (se recarga al re-entrar).
final missionInitProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.watch(timeInitProvider.future);
  await ref.read(missionProvider.notifier).getMissions();
});

class MissionNotifier extends StateNotifier<MissionState> {
  MissionNotifier(this.ref) : super(const MissionState()) {
    _init();
  }

  final Ref ref;
  final MissionRepository repository = getIt<MissionRepository>();

  StreamSubscription<Map<String, dynamic>>? _missionsSub;

  void _init() {
    ref.listen<bool>(
      internetStatusProvider.select((async) => async.value ?? false),
      (previous, hasInternet) {
        if (!hasInternet) {
          initData();
        }
      },
    );
  }

  void initData() {
    state = state.copyWith(
      dailyRewards: const [],
      weeklyReward: null,
      monthlyReward: null,
    );
  }

  /// Inicializa las misiones y se suscribe a los streams del WebSocket
  Future<void> initDataMissions() async {
    // Obtiene la instancia del socket desde Riverpod
    final socket = ref.read(websocketServiceProvider);
    // Evita suscripciones duplicadas si se recarga la pantalla.
    await _missionsSub?.cancel();
    // 🎯 Escucha las misiones en tiempo real
    _missionsSub = socket.missionsStream.listen((missions) {
      final board = MissionMapper.fromSocketData(missions);
      state = state.copyWith(
        dailyRewards: board.dailyRewards,
        weeklyReward: board.weeklyReward,
        monthlyReward: board.monthlyReward,
      );
    });
  }

  /// Carga inicial vía HTTP + suscripción a actualizaciones en vivo.
  /// Lanza [ServiceException] si falla; la UI lo maneja vía AsyncValue.
  Future<void> getMissions() async {
    await initDataMissions();
    final board = await repository.getMissions();
    state = state.copyWith(
      dailyRewards: board.dailyRewards,
      weeklyReward: board.weeklyReward,
      monthlyReward: board.monthlyReward,
    );
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

class MissionState extends Equatable {
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

  @override
  List<Object?> get props => [monthlyReward, weeklyReward, dailyRewards];
}
