import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/config/constants/api_endpoints.dart';
import 'package:pixel_retro_app/app/features/home/data/dtos/get_game_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/home/data/mappers/game_mapper.dart';
import 'package:pixel_retro_app/app/features/home/domain/datasources/home_datasource.dart';
import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';

class HomeDataSourceImpl implements HomeDataSource {
  HomeDataSourceImpl(this._api);

  final Api _api;

  @override
  Future<List<GameEntity>> getGames() async {
    try {
      final response = await _api.get(ApiEndpoints.listGames);
      final dto = GetGameListResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return GameMapper.fromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener los juegos',
      );
    }
  }
}
