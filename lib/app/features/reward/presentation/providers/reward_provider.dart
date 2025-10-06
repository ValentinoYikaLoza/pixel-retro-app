import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/time_entity.dart';
import 'package:pixel_retro_app/app/features/reward/domain/entities/reward_entity.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/get_reward_list_response_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/get_time_left_list_response_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/repositories/reward_repository.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final rewardProvider = StateNotifierProvider<RewardNotifier, RewardState>((
  ref,
) {
  return RewardNotifier(ref);
});

class RewardNotifier extends StateNotifier<RewardState> {
  RewardNotifier(this.ref) : super(const RewardState());

  final Ref ref;
  final RewardRepository repository = getIt<RewardRepository>();

  Future<void> getRewards() async {
    try {
      final GetRewardListResponseModel response = await repository.getRewards();
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

  String getRewardImage(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'assets/icons/gold-chest.svg';
      case 2:
        return 'assets/icons/silver-chest.svg';
      case 3:
        return 'assets/icons/bronze-chest.svg';
      default:
        return 'assets/icons/bronze-chest.svg';
    }
  }
}

class RewardState {
  final RewardEntity? monthlyReward;
  final RewardEntity? weeklyReward;
  final List<RewardEntity> dailyRewards;
  final TimeEntity? timeLeftUntilNextMonth;
  final TimeEntity? timeLeftUntilNextWeek;
  final TimeEntity? timeLeftUntilNextDay;
  final String currentMonth;

  const RewardState({
    this.monthlyReward,
    this.weeklyReward,
    this.dailyRewards = const [],
    this.timeLeftUntilNextMonth,
    this.timeLeftUntilNextWeek,
    this.timeLeftUntilNextDay,
    this.currentMonth = '',
  });

  RewardState copyWith({
    RewardEntity? monthlyReward,
    RewardEntity? weeklyReward,
    List<RewardEntity>? dailyRewards,
    TimeEntity? timeLeftUntilNextMonth,
    TimeEntity? timeLeftUntilNextWeek,
    TimeEntity? timeLeftUntilNextDay,
    String? currentMonth,
  }) {
    return RewardState(
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
