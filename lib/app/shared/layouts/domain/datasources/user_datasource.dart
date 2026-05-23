import 'package:pixel_retro_app/app/shared/layouts/domain/entities/user_stats_entity.dart';

abstract class UserDataSource {
  Future<UserStatsEntity> getUser();
  Future<void> updateCoins(int coins);
  Future<void> updateLives(int lives);
  Future<void> updateStreak();
  Future<void> updateExp(int exp);
}
