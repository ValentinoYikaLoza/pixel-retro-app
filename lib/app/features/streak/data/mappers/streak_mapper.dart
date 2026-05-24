import 'package:pixel_retro_app/app/features/streak/data/dtos/get_streak_response_dto.dart';
import 'package:pixel_retro_app/app/features/streak/domain/entities/streak_overview_entity.dart';

class StreakMapper {
  const StreakMapper._();

  static StreakOverviewEntity fromDto(GetStreakResponseDto dto) {
    final d = dto.data;
    return StreakOverviewEntity(
      streak: d.streak,
      freezes: d.freezes,
      lastStreakDate: d.lastStreakDate,
      freezeCost: d.freezeCost,
      maxFreezes: d.maxFreezes,
      month: d.month,
      daysInMonth: d.daysInMonth,
      checkedInDays: d.checkedInDays,
      monthCount: d.monthCount,
      goals: d.goals
          .map(
            (g) => StreakGoalEntity(
              id: g.id,
              daysRequired: g.daysRequired,
              rewardCoins: g.rewardCoins,
              rewardFreezes: g.rewardFreezes,
              rewardExp: g.rewardExp,
              progress: g.progress,
              claimed: g.claimed,
              claimable: g.claimable,
            ),
          )
          .toList(),
      milestones: d.milestones
          .map(
            (m) => StreakMilestoneEntity(
              days: m.days,
              rewardCoins: m.rewardCoins,
              reached: m.reached,
            ),
          )
          .toList(),
    );
  }
}
