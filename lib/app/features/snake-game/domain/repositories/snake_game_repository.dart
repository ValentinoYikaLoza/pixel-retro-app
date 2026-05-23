import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_leaderboard_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_session_entity.dart';

abstract class SnakeGameRepository {
  Future<List<GameLevelEntity>> listLevels(String gameCode);

  Future<GameSessionEntity> startGame(String gameCode, int level);

  Future<GameResultEntity> finishGame({
    required int sessionId,
    required int score,
    required int foodEaten,
    required int durationMs,
  });

  Future<int> doubleReward(int sessionId);

  Future<void> abandonGame(int sessionId);

  Future<GameLeaderboardEntity> getLeaderboard(String gameCode);
}
