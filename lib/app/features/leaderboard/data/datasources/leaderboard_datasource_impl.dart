import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_division_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/get_division_list_response_mapper.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/datasources/leaderboard_datasource.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/main.dart';

final api = Api();
final userId = globalUserId;

class LeaderboardDatasourceImpl implements LeaderboardDatasource {
  @override
  Future<void> getUsers() async {
    try {
      Map<String, String> formData = {'user_id': userId.toString()};

      final response = await api.post('/listUsers', data: formData);
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
  Future<GetDivisionListResponseModel> getDivisions() async {
    try {
      final response = await api.get('/listDivisions');
      if (response.statusCode == 200) {
        final dto = GetDivisionListResponseDto.fromJson(response.data);
        return GetDivisionListResponseMapper.fromDtoToModel(dto);
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'An error occurred, $e';
    }
  }
}
