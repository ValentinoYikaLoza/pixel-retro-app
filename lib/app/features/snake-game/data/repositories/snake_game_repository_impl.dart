import 'package:pixel_retro_app/app/features/snake-game/domain/datasources/snake_game_datasource.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_leaderboard_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_session_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/repositories/snake_game_repository.dart';

class SnakeGameRepositoryImpl implements SnakeGameRepository {
  final SnakeGameDataSource dataSource;

  SnakeGameRepositoryImpl(this.dataSource);

  @override
  Future<GameSessionEntity> startGame(String gameCode) {
    return dataSource.startGame(gameCode);
  }

  @override
  Future<GameResultEntity> finishGame({
    required int sessionId,
    required int score,
    required int foodEaten,
    required int durationMs,
  }) {
    return dataSource.finishGame(
      sessionId: sessionId,
      score: score,
      foodEaten: foodEaten,
      durationMs: durationMs,
    );
  }

  @override
  Future<int> doubleReward(int sessionId) {
    return dataSource.doubleReward(sessionId);
  }

  @override
  Future<void> abandonGame(int sessionId) {
    return dataSource.abandonGame(sessionId);
  }

  @override
  Future<GameLeaderboardEntity> getLeaderboard(String gameCode) {
    return dataSource.getLeaderboard(gameCode);
  }
}
