import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/config/constants/api_endpoints.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_division_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_user_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/get_division_list_response_mapper.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/user_mapper.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/datasources/leaderboard_datasource.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/app/shared/services/session_service.dart';

class LeaderboardDatasourceImpl implements LeaderboardDatasource {
  LeaderboardDatasourceImpl(this._api, this._session);

  final Api _api;
  final SessionService _session;

  /// Tope por defecto de usuarios del ranking (acota el payload).
  static const int _defaultLimit = 50;

  @override
  Future<List<UserDivisionEntity>> getUsers({int? limit}) async {
    try {
      final formData = {
        'user_id': _session.userId,
        'limit': '${limit ?? _defaultLimit}',
      };
      final response = await _api.post(ApiEndpoints.listUsers, data: formData);
      final dto = GetUserListResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return UserMapper.fromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener los usuarios',
      );
    }
  }

  @override
  Future<List<DivisionEntity>> getDivisions() async {
    try {
      final response = await _api.get(ApiEndpoints.listDivisions);
      final dto = GetDivisionListResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return GetDivisionListResponseMapper.fromDtoToEntities(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener las divisiones',
      );
    }
  }
}
