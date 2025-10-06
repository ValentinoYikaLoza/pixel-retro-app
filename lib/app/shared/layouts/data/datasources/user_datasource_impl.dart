import 'package:pixel_retro_app/app/shared/layouts/domain/datasources/user_datasource.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/entities/user_entity.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/models/get_user_response_model.dart';

class UserDataSourceImpl implements UserDataSource {
  @override
  Future<GetUserResponseModel> getUser() {
    return Future.delayed(Duration(milliseconds: 200), () {
      return GetUserResponseModel(
        user: UserEntity(
          id: 1,
          name: 'Valentino',
          coins: 100,
          lives: 5,
          streak: 0,
        ),
      );
    });
  }

  @override
  Future<void> updateCoins(int coins, bool add) {
    return Future.delayed(const Duration(milliseconds: 200), () => null);
  }

  @override
  Future<void> updateLives(int lives, bool add) {
    return Future.delayed(const Duration(milliseconds: 200), () => null);
  }

  @override
  Future<void> updateStreak() {
    return Future.delayed(const Duration(milliseconds: 200), () => null);
  }

  @override
  Future<void> updateExp(int exp) {
    return Future.delayed(const Duration(milliseconds: 200), () => null);
  }
}
