import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/dtos/get_user_response_dto.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/mappers/get_user_response_mapper.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/datasources/user_datasource.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/models/get_user_response_model.dart';

final api = Api();

class UserDataSourceImpl implements UserDataSource {
  @override
  Future<GetUserResponseModel> getUser() async {
    try {
      Map<String, String> formData = {'user_id': '1'};

      final response = await api.post('/getUser', data: formData);
      if (response.statusCode == 200) {
        final dto = GetUserResponseDto.fromJson(response.data);
        return GetUserResponseMapper.fromDtoToModel(dto);
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'An error occurred, $e';
    }
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
