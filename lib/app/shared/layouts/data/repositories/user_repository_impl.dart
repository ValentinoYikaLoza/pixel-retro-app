import 'package:pixel_retro_app/app/shared/layouts/domain/datasources/user_datasource.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/entities/user_stats_entity.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<UserStatsEntity> getUser() {
    return _dataSource.getUser();
  }

  @override
  Future<void> updateCoins(int coins) {
    return _dataSource.updateCoins(coins);
  }

  @override
  Future<void> updateLives(int lives) {
    return _dataSource.updateLives(lives);
  }

  @override
  Future<void> updateStreak() {
    return _dataSource.updateStreak();
  }

  @override
  Future<void> updateExp(int exp) {
    return _dataSource.updateExp(exp);
  }
}
