import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/config/constants/api_endpoints.dart';
import 'package:pixel_retro_app/app/features/mission/data/dtos/get_mission_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/mission/data/mappers/mission_mapper.dart';
import 'package:pixel_retro_app/app/features/mission/domain/datasources/mission_datasource.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/missions_board_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/update_progress_request_model.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/app/shared/services/session_service.dart';

class MissionDataSourceImpl implements MissionDataSource {
  MissionDataSourceImpl(this._api, this._session);

  final Api _api;
  final SessionService _session;

  @override
  Future<MissionsBoardEntity> getMissions() async {
    try {
      final formData = {'user_id': _session.userId};
      final response = await _api.post(
        ApiEndpoints.listMissions,
        data: formData,
      );
      final dto = GetMissionListResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return MissionMapper.fromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener las misiones',
      );
    }
  }

  @override
  Future<void> updateProgress(UpdateProgressRequestModel request) async {
    try {
      final formData = {
        'user_id': request.userId,
        'reward_id': request.rewardId,
        'current_points': '${request.currentPoints}',
      };
      await _api.post(ApiEndpoints.updateProgress, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al actualizar el progreso',
      );
    }
  }
}
