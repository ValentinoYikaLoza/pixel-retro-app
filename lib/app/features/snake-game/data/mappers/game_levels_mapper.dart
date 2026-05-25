import 'package:pixel_retro_app/app/features/snake-game/data/dtos/game_levels_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_session_mapper.dart'
    show wallsToOffsets;
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';

class GameLevelsMapper {
  static List<GameLevelEntity> fromDto(GameLevelsResponseDto dto) {
    return dto.levels
        .map(
          (l) => GameLevelEntity(
            level: l.level,
            tickMs: l.tickMs,
            gridWidth: l.gridWidth,
            gridHeight: l.gridHeight,
            wrapAround: l.wrapAround,
            walls: wallsToOffsets(l.walls),
            targetScore: l.targetScore,
            bestScore: l.bestScore,
            bestPoints: l.bestPoints,
            cleared: l.cleared,
            unlocked: l.unlocked,
          ),
        )
        .toList();
  }
}
