import 'package:pixel_retro_app/app/features/home/data/dtos/get_game_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';

class GameMapper {
  /// Solo expone los juegos habilitados (el server puede desactivar alguno).
  static List<GameEntity> fromDto(GetGameListResponseDto dto) {
    return dto.data
        .where((g) => g.enabled)
        .map((g) => GameEntity(id: g.id, code: g.code, title: g.title))
        .toList();
  }
}
