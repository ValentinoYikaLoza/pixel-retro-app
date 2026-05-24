import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/config/constants/api_endpoints.dart';
import 'package:pixel_retro_app/app/features/streak/data/dtos/get_streak_response_dto.dart';
import 'package:pixel_retro_app/app/features/streak/data/mappers/streak_mapper.dart';
import 'package:pixel_retro_app/app/features/streak/domain/datasources/streak_datasource.dart';
import 'package:pixel_retro_app/app/features/streak/domain/entities/streak_overview_entity.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/app/shared/services/session_service.dart';

class StreakDataSourceImpl implements StreakDataSource {
  StreakDataSourceImpl(this._api, this._session);

  final Api _api;
  final SessionService _session;

  StreakOverviewEntity _parse(dynamic data) {
    final dto = GetStreakResponseDto.fromJson(
      data as Map<String, dynamic>? ?? const {},
    );
    return StreakMapper.fromDto(dto);
  }

  @override
  Future<StreakOverviewEntity> getStreak() async {
    try {
      final response = await _api.post(
        ApiEndpoints.getStreak,
        data: {'user_id': _session.userId},
      );
      return _parse(response.data);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener la racha',
      );
    }
  }

  @override
  Future<StreakOverviewEntity> claimGoal(int goalId) async {
    try {
      final response = await _api.post(
        ApiEndpoints.claimStreakGoal,
        data: {'user_id': _session.userId, 'goal_id': '$goalId'},
      );
      return _parse(response.data);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al reclamar la meta',
      );
    }
  }

  @override
  Future<StreakOverviewEntity> buyFreeze() async {
    try {
      final response = await _api.post(
        ApiEndpoints.buyStreakFreeze,
        data: {'user_id': _session.userId},
      );
      return _parse(response.data);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al comprar el congelador',
      );
    }
  }
}
