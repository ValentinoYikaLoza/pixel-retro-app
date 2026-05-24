import 'package:equatable/equatable.dart';

/// Resumen de la racha del usuario para un mes: racha actual, congeladores,
/// días con check-in (calendario), metas mensuales e hitos consecutivos.
class StreakOverviewEntity extends Equatable {
  final int streak;
  final int freezes;
  final String? lastStreakDate;
  final int freezeCost;
  final int maxFreezes;

  /// Mes del calendario en formato 'YYYY-MM' (UTC).
  final String month;
  final int daysInMonth;

  /// Días del mes (números 1..daysInMonth) con check-in.
  final List<int> checkedInDays;
  final int monthCount;

  final List<StreakGoalEntity> goals;
  final List<StreakMilestoneEntity> milestones;

  const StreakOverviewEntity({
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

  bool get canBuyFreeze => freezes < maxFreezes;

  @override
  List<Object?> get props => [
    streak,
    freezes,
    lastStreakDate,
    freezeCost,
    maxFreezes,
    month,
    daysInMonth,
    checkedInDays,
    monthCount,
    goals,
    milestones,
  ];
}

/// Meta mensual: entrar [daysRequired] días en el mes otorga la recompensa.
class StreakGoalEntity extends Equatable {
  final int id;
  final int daysRequired;
  final int rewardCoins;
  final int rewardFreezes;
  final int rewardExp;
  final int progress;
  final bool claimed;
  final bool claimable;

  const StreakGoalEntity({
    required this.id,
    required this.daysRequired,
    required this.rewardCoins,
    required this.rewardFreezes,
    required this.rewardExp,
    required this.progress,
    required this.claimed,
    required this.claimable,
  });

  @override
  List<Object?> get props => [
    id,
    daysRequired,
    rewardCoins,
    rewardFreezes,
    rewardExp,
    progress,
    claimed,
    claimable,
  ];
}

/// Hito por racha consecutiva: al llegar a [days] seguidos se otorgan monedas.
class StreakMilestoneEntity extends Equatable {
  final int days;
  final int rewardCoins;
  final bool reached;

  const StreakMilestoneEntity({
    required this.days,
    required this.rewardCoins,
    required this.reached,
  });

  @override
  List<Object?> get props => [days, rewardCoins, reached];
}
