import 'package:pixel_retro_app/app/features/snake-game/data/dtos/finish_game_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';

class GameResultMapper {
  static GameResultEntity fromDto(FinishGameResponseDto dto) {
    return GameResultEntity(
      isHighScore: dto.data.isHighScore,
      highScore: dto.data.highScore,
      expGained: dto.data.expGained,
      coinsGained: dto.data.coinsGained,
    );
  }
}
