import 'package:pixel_retro_app/app/shared/layouts/domain/datasources/user_datasource.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/models/get_user_response_model.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<GetUserResponseModel> getUser() {
    return _dataSource.getUser();
  }

  @override
  Future<void> updateCoins(int coins, bool add) {
    return _dataSource.updateCoins(coins, add);
  }

  @override
  Future<void> updateLives(int lives, bool add) {
    return _dataSource.updateLives(lives, add);
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
