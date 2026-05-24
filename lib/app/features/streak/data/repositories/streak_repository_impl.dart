import 'package:pixel_retro_app/app/features/streak/domain/datasources/streak_datasource.dart';
import 'package:pixel_retro_app/app/features/streak/domain/entities/streak_overview_entity.dart';
import 'package:pixel_retro_app/app/features/streak/domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._dataSource);

  final StreakDataSource _dataSource;

  @override
  Future<StreakOverviewEntity> getStreak() => _dataSource.getStreak();

  @override
  Future<StreakOverviewEntity> claimGoal(int goalId) =>
      _dataSource.claimGoal(goalId);

  @override
  Future<StreakOverviewEntity> buyFreeze() => _dataSource.buyFreeze();
}
