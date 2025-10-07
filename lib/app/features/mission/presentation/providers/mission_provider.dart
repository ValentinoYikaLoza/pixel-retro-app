import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/time_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_mission_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_time_left_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/repositories/mission_repository.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
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

  Future<void> getMissions() async {
    try {
      final GetMissionListResponseModel response = await repository
          .getMissions();
      state = state.copyWith(
        monthlyReward: response.monthlyReward,
        weeklyReward: response.weeklyReward,
        dailyRewards: response.dailyRewards,
      );
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo la lista de recompensas',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> getTimeLeftList() async {
    try {
      final GetTimeLeftListResponseModel response = await repository
          .getTimeLeftList();
      state = state.copyWith(
        timeLeftUntilNextMonth: response.timeLeftUntilNextMonth,
        timeLeftUntilNextWeek: response.timeLeftUntilNextWeek,
        timeLeftUntilNextDay: response.timeLeftUntilNextDay,
      );
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo los tiempos restantes',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> getCurrentMonth() async {
    try {
      final String response = await repository.getCurrentMonth();
      state = state.copyWith(currentMonth: response);
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo el mes actual',
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
}

class MissionState {
  final MissionEntity? monthlyReward;
  final MissionEntity? weeklyReward;
  final List<MissionEntity> dailyRewards;
  final TimeEntity? timeLeftUntilNextMonth;
  final TimeEntity? timeLeftUntilNextWeek;
  final TimeEntity? timeLeftUntilNextDay;
  final String currentMonth;

  const MissionState({
    this.monthlyReward,
    this.weeklyReward,
    this.dailyRewards = const [],
    this.timeLeftUntilNextMonth,
    this.timeLeftUntilNextWeek,
    this.timeLeftUntilNextDay,
    this.currentMonth = '',
  });

  MissionState copyWith({
    MissionEntity? monthlyReward,
    MissionEntity? weeklyReward,
    List<MissionEntity>? dailyRewards,
    TimeEntity? timeLeftUntilNextMonth,
    TimeEntity? timeLeftUntilNextWeek,
    TimeEntity? timeLeftUntilNextDay,
    String? currentMonth,
  }) {
    return MissionState(
      monthlyReward: monthlyReward ?? this.monthlyReward,
      weeklyReward: weeklyReward ?? this.weeklyReward,
      dailyRewards: dailyRewards ?? this.dailyRewards,
      timeLeftUntilNextMonth:
          timeLeftUntilNextMonth ?? this.timeLeftUntilNextMonth,
      timeLeftUntilNextWeek:
          timeLeftUntilNextWeek ?? this.timeLeftUntilNextWeek,
      timeLeftUntilNextDay: timeLeftUntilNextDay ?? this.timeLeftUntilNextDay,
      currentMonth: currentMonth ?? this.currentMonth,
    );
  }
}
