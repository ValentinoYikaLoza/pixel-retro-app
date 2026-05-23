import 'package:pixel_retro_app/app/features/snake-game/data/dtos/start_game_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_session_entity.dart';

class GameSessionMapper {
  static GameSessionEntity fromDto(StartGameResponseDto dto) {
    return GameSessionEntity(
      sessionId: dto.data.sessionId,
      seed: dto.data.seed,
      tickMs: dto.data.tickMs,
      gridWidth: dto.data.gridWidth,
      gridHeight: dto.data.gridHeight,
      livesLeft: dto.data.livesLeft,
    );
  }
}
