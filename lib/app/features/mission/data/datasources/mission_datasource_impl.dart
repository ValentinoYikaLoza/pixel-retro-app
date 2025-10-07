import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/features/mission/data/dtos/get_current_month_response_dto.dart';
import 'package:pixel_retro_app/app/features/mission/data/dtos/get_mission_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/mission/data/dtos/get_time_left_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/mission/data/mappers/get_current_month_response_mapper.dart';
import 'package:pixel_retro_app/app/features/mission/data/mappers/get_mission_list_response_mapper.dart';
import 'package:pixel_retro_app/app/features/mission/data/mappers/get_time_left_list_response_mapper.dart';
import 'package:pixel_retro_app/app/features/mission/domain/datasources/mission_datasource.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_mission_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_time_left_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/update_progress_request_model.dart';

final api = Api();

class MissionDataSourceImpl implements MissionDataSource {
  @override
  Future<GetMissionListResponseModel> getMissions() async {
    try {
      Map<String, String> formData = {'user_id': '1'};

      final response = await api.post('/listMissions', data: formData);
      if (response.statusCode == 200) {
        final dto = GetMissionListResponseDto.fromJson(response.data);
        return GetMissionListResponseMapper.fromDtoToModel(dto);
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'An error occurred, $e';
    }
  }

  @override
  Future<void> updateProgress(UpdateProgressRequestModel request) {
    return Future.delayed(Duration(milliseconds: 200), () {
      return;
    });
  }

  @override
  Future<GetTimeLeftListResponseModel> getTimeLeftList() async {
    try {
      final response = await api.get('/getTimeLeft');
      if (response.statusCode == 200) {
        final dto = GetTimeLeftListResponseDto.fromJson(response.data);
        return GetTimeLeftListResponseMapper.fromDtoToModel(dto);
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'An error occurred, $e';
    }
  }

  @override
  Future<String> getCurrentMonth() async {
    try {
      final response = await api.get('/getCurrentMonth');
      if (response.statusCode == 200) {
        final dto = GetCurrentMonthResponseDto.fromJson(response.data);
        return GetCurrentMonthResponseMapper.fromDtoToModel(dto);
      } else {
        throw 'An error occurred, status code: ${response.statusCode}';
      }
    } catch (e) {
      throw 'An error occurred, $e';
    }
  }
}
