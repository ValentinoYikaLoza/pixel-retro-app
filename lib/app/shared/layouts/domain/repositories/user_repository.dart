import 'package:pixel_retro_app/app/shared/layouts/domain/models/get_user_response_model.dart';

abstract class UserRepository {
  Future<GetUserResponseModel> getUser();
  Future<void> updateCoins(int coins, bool add);
  Future<void> updateLives(int lives, bool add);
  Future<void> updateStreak();
  Future<void> updateExp(int exp);
}
