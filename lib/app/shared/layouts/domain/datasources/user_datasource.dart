abstract class UserDataSource {
  Future<void> getUser();
  Future<void> updateCoins(int coins);
  Future<void> updateLives(int lives);
  Future<void> updateStreak();
  Future<void> updateExp(int exp);
}
