/// Respuesta de `POST /getStreak` (y de claim/buy, que devuelven el mismo
/// resumen). Forma: `{ success, message, data: { streak, freezes, ...,
/// checked_in_days: [], goals: [], milestones: [] } }`. Parseo defensivo.
class GetStreakResponseDto {
  final bool success;
  final String message;
  final StreakData data;

  GetStreakResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetStreakResponseDto.fromJson(Map<String, dynamic> json) {
    return GetStreakResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: StreakData.fromJson(json['data'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class StreakData {
  final int streak;
  final int freezes;
  final String? lastStreakDate;
  final int freezeCost;
  final int maxFreezes;
  final String month;
  final int daysInMonth;
  final List<int> checkedInDays;
  final int monthCount;
  final List<StreakGoalDto> goals;
  final List<StreakMilestoneDto> milestones;

  StreakData({
    required this.streak,
    required this.freezes,
    required this.lastStreakDate,
    required this.freezeCost,
    required this.maxFreezes,
    required this.month,
    required this.daysInMonth,
    required this.checkedInDays,
    required this.monthCount,
    required this.goals,
    required this.milestones,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      freezes: (json['freezes'] as num?)?.toInt() ?? 0,
      lastStreakDate: json['last_streak_date']?.toString(),
      freezeCost: (json['freeze_cost'] as num?)?.toInt() ?? 0,
      maxFreezes: (json['max_freezes'] as num?)?.toInt() ?? 0,
      month: json['month']?.toString() ?? '',
      daysInMonth: (json['days_in_month'] as num?)?.toInt() ?? 30,
      checkedInDays: (json['checked_in_days'] as List<dynamic>? ?? [])
          .map((e) => (e as num?)?.toInt() ?? 0)
          .where((d) => d > 0)
          .toList(),
      monthCount: (json['month_count'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as List<dynamic>? ?? [])
          .map((e) => StreakGoalDto.fromJson(e as Map<String, dynamic>? ?? const {}))
          .toList(),
      milestones: (json['milestones'] as List<dynamic>? ?? [])
          .map((e) => StreakMilestoneDto.fromJson(e as Map<String, dynamic>? ?? const {}))
          .toList(),
    );
  }
}

class StreakGoalDto {
  final int id;
  final int daysRequired;
  final int rewardCoins;
  final int rewardFreezes;
  final int rewardExp;
  final int progress;
  final bool claimed;
  final bool claimable;

  StreakGoalDto({
    required this.id,
    required this.daysRequired,
    required this.rewardCoins,
    required this.rewardFreezes,
    required this.rewardExp,
    required this.progress,
    required this.claimed,
    required this.claimable,
  });

  factory StreakGoalDto.fromJson(Map<String, dynamic> json) {
    return StreakGoalDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      daysRequired: (json['days_required'] as num?)?.toInt() ?? 0,
      rewardCoins: (json['reward_coins'] as num?)?.toInt() ?? 0,
      rewardFreezes: (json['reward_freezes'] as num?)?.toInt() ?? 0,
      rewardExp: (json['reward_exp'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      claimed: json['claimed'] as bool? ?? false,
      claimable: json['claimable'] as bool? ?? false,
    );
  }
}

class StreakMilestoneDto {
  final int days;
  final int rewardCoins;
  final bool reached;

  StreakMilestoneDto({
    required this.days,
    required this.rewardCoins,
    required this.reached,
  });

  factory StreakMilestoneDto.fromJson(Map<String, dynamic> json) {
    return StreakMilestoneDto(
      days: (json['days'] as num?)?.toInt() ?? 0,
      rewardCoins: (json['reward_coins'] as num?)?.toInt() ?? 0,
      reached: json['reached'] as bool? ?? false,
    );
  }
}
