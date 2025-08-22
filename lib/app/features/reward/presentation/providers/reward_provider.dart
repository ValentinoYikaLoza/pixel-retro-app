import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pixel_retro_app/app/features/reward/presentation/data/reward_data.dart';

final rewardProvider = StateNotifierProvider<RewardNotifier, RewardState>((
  ref,
) {
  return RewardNotifier(ref);
});

class RewardNotifier extends StateNotifier<RewardState> {
  RewardNotifier(this.ref) : super(const RewardState());

  final Ref ref;

  void initData() {
    final List<RewardModel> rewards = rewardData;

    final RewardModel monthlyRewardData = rewards
        .where((reward) => reward.type == RewardType.monthly)
        .toList()
        .first;

    final RewardModel weeklyRewardData = rewards
        .where((reward) => reward.type == RewardType.weekly)
        .toList()
        .first;

    final List<RewardModel> dailyRewardsData = rewards
        .where((reward) => reward.type == RewardType.daily)
        .toList();

    state = state.copyWith(
      today: () => DateTime.now(),
      monthlyReward: monthlyRewardData,
      weeklyReward: weeklyRewardData,
      dailyRewards: dailyRewardsData,
    );
  }
}

class RewardState {
  final DateTime? today;
  final RewardModel? monthlyReward;
  final RewardModel? weeklyReward;
  final List<RewardModel> dailyRewards;

  String get monthName {
    if (today == null) return '';

    final format = DateFormat('MMMM', 'es_ES');
    return format.format(today!);
  }

  int get daysLeftUntilSunday {
    if (today == null) return 0;

    final daysLeft = DateTime.sunday - today!.weekday;
    return daysLeft;
  }

  int get daysLeftUntilNextMonth {
    if (today == null) return 0;

    final nextMonth = DateTime(today!.year, today!.month + 1, 1);
    final daysLeft = nextMonth.difference(today!).inDays;
    return daysLeft;
  }

  int get hoursLeftUntilEndOfDay {
    if (today == null) return 0;

    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final hoursLeft = endOfDay.difference(now).inHours;
    return hoursLeft;
  }

  const RewardState({
    this.today,
    this.monthlyReward,
    this.weeklyReward,
    this.dailyRewards = const [],
  });

  RewardState copyWith({
    ValueGetter<DateTime>? today,
    RewardModel? monthlyReward,
    RewardModel? weeklyReward,
    List<RewardModel>? dailyRewards,
  }) {
    return RewardState(
      today: today != null ? today() : this.today,
      monthlyReward: monthlyReward ?? this.monthlyReward,
      weeklyReward: weeklyReward ?? this.weeklyReward,
      dailyRewards: dailyRewards ?? this.dailyRewards,
    );
  }
}

enum RewardStatus { claimed, unclaimed }

enum RewardType { daily, weekly, monthly }

enum RewardCategory { bronze, silver, gold }

class RewardModel {
  final String id;
  final String description;
  final RewardType type;
  final RewardCategory category;
  final RewardStatus status;
  final String imageUrl;
  final int currentPoints;
  final int totalPoints;

  RewardModel({
    required this.id,
    required this.description,
    required this.type,
    required this.category,
    required this.status,
    required this.imageUrl,
    required this.currentPoints,
    required this.totalPoints,
  });
}
