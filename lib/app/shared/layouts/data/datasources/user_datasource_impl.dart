import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/datasources/user_datasource.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/main.dart';

final api = Api();
final userId = globalUserId;

class UserDataSourceImpl implements UserDataSource {
  @override
  Future<void> getUser() async {
    try {
      Map<String, String> formData = {'user_id': userId.toString()};
      final response = await api.post('/getUser', data: formData);
      if (response.statusCode == 200) {
        return;
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      String errorMessage = ErrorService.verificarErrorBase(
        'Ocurrió un error',
        e,
      );
      throw ServiceException(errorMessage);
    }
  }

  @override
  Future<void> updateCoins(int coins) async {
    try {
      Map<String, String> formData = {
        'user_id': userId.toString(),
        'coins': '$coins',
      };

      final response = await api.post('/updateCoins', data: formData);
      if (response.statusCode == 200) {
        return;
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      String errorMessage = ErrorService.verificarErrorBase(
        'Ocurrió un error',
        e,
      );
      throw ServiceException(errorMessage);
    }
  }

  @override
  Future<void> updateLives(int lives) async {
    try {
      Map<String, String> formData = {
        'user_id': userId.toString(),
        'lives': '$lives',
      };

      final response = await api.post('/updateLives', data: formData);
      if (response.statusCode == 200) {
        return;
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      String errorMessage = ErrorService.verificarErrorBase(
        'Ocurrió un error',
        e,
      );
      throw ServiceException(errorMessage);
    }
  }

  @override
  Future<void> updateStreak() async {
    try {
      Map<String, String> formData = {'user_id': userId.toString()};

      final response = await api.post('/updateStreak', data: formData);
      if (response.statusCode == 200) {
        return;
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      String errorMessage = ErrorService.verificarErrorBase(
        'Ocurrió un error',
        e,
      );
      throw ServiceException(errorMessage);
    }
  }

  @override
  Future<void> updateExp(int exp) {
    return Future.delayed(const Duration(milliseconds: 200), () => null);
  }
}
