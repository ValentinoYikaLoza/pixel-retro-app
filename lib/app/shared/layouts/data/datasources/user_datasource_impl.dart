import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/config/constants/api_endpoints.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/dtos/get_user_response_dto.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/mappers/user_stats_mapper.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/datasources/user_datasource.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/entities/user_stats_entity.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/app/shared/services/session_service.dart';

class UserDataSourceImpl implements UserDataSource {
  UserDataSourceImpl(this._api, this._session);

  final Api _api;
  final SessionService _session;

  @override
  Future<UserStatsEntity> getUser() async {
    try {
      final formData = {'user_id': _session.userId};
      final response = await _api.post(ApiEndpoints.getUser, data: formData);
      final dto = GetUserResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return UserStatsMapper.fromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener el usuario',
      );
    }
  }

  @override
  Future<void> updateCoins(int coins) async {
    try {
      final formData = {'user_id': _session.userId, 'coins': '$coins'};
      await _api.post(ApiEndpoints.updateCoins, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al actualizar las monedas',
      );
    }
  }

  @override
  Future<void> updateLives(int lives) async {
    try {
      final formData = {'user_id': _session.userId, 'lives': '$lives'};
      await _api.post(ApiEndpoints.updateLives, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al actualizar las vidas',
      );
    }
  }

  @override
  Future<void> updateStreak() async {
    try {
      final formData = {'user_id': _session.userId};
      await _api.post(ApiEndpoints.updateStreak, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al actualizar la racha',
      );
    }
  }

  @override
  Future<void> updateExp(int exp) async {
    try {
      final formData = {'user_id': _session.userId, 'exp': '$exp'};
      await _api.post(ApiEndpoints.updateExp, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al actualizar la experiencia',
      );
    }
  }
}
