import 'package:pixel_retro_app/app/features/streak/domain/entities/streak_overview_entity.dart';

abstract class StreakDataSource {
  Future<StreakOverviewEntity> getStreak();
  Future<StreakOverviewEntity> claimGoal(int goalId);
  Future<StreakOverviewEntity> buyFreeze();
}
