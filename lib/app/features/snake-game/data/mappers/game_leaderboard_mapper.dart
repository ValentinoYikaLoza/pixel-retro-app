import 'package:pixel_retro_app/app/features/snake-game/data/dtos/game_leaderboard_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_leaderboard_entity.dart';

class GameLeaderboardMapper {
  static GameLeaderboardEntity fromDto(GameLeaderboardResponseDto dto) {
    return GameLeaderboardEntity(
      entries: dto.leaderboard
          .map(
            (e) => GameLeaderboardEntryEntity(
              userId: e.userId,
              name: e.name,
              highScore: e.highScore,
              totalGames: e.totalGames,
              flag: e.flag,
            ),
          )
          .toList(),
      myHighScore: dto.me.highScore,
      myTotalGames: dto.me.totalGames,
      myTotalScore: dto.me.totalScore,
    );
  }
}
