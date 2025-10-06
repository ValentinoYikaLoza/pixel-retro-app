import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_current_division_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_division_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_time_left_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_user_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/get_current_division_response_mapper.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/get_division_list_response_mapper.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/get_time_left_response_mapper.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/get_user_list_response_mapper.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/datasources/leaderboard_datasource.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_current_division_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_time_left_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_user_list_response_model.dart';

final api = Api();

class LeaderboardDatasourceImpl implements LeaderboardDatasource {
  @override
  Future<GetUserListResponseModel> getUsers() async {
    try {
      Map<String, String> formData = {'user_id': '1'};

      final response = await api.post('/listUsers', data: formData);
      if (response.statusCode == 200) {
        final dto = GetUserListResponseDto.fromJson(response.data);
        return GetUserListResponseMapper.fromDtoToModel(dto);
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'An error occurred, $e';
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

  @override
  Future<GetTimeLeftResponseModel> getTimeLeft() async {
    try {
      final response = await api.get('/getTimeLeftTillNextWeek');
      if (response.statusCode == 200) {
        final dto = GetTimeLeftResponseDto.fromJson(response.data);
        return GetTimeLeftResponseMapper.fromDtoToModel(dto);
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'An error occurred, $e';
    }
  }

  @override
  Future<GetCurrentDivisionResponseModel> getCurrentDivision() async {
    try {
      Map<String, String> formData = {'user_id': '1'};

      final response = await api.post('/getCurrentDivision', data: formData);
      if (response.statusCode == 200) {
        final dto = GetCurrentDivisionResponseDto.fromJson(response.data);
        return GetCurrentDivisionResponseMapper.fromDtoToModel(dto);
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'An error occurred, $e';
    }
  }
}
