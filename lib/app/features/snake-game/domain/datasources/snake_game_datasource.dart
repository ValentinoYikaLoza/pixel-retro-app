import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_leaderboard_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_session_entity.dart';

/// Ciclo de vida de una partida contra el backend (autoridad del servidor).
abstract class SnakeGameDataSource {
  /// Abre una partida: consume vida y devuelve semilla + config.
  Future<GameSessionEntity> startGame(String gameCode);

  /// Cierra una partida y devuelve las recompensas otorgadas.
  Future<GameResultEntity> finishGame({
    required int sessionId,
    required int score,
    required int foodEaten,
    required int durationMs,
  });

  /// Duplica los puntos (exp) de una partida terminada tras ver un anuncio.
  /// Devuelve la exp extra otorgada (0 si ya se había cobrado).
  Future<int> doubleReward(int sessionId);

  /// Marca una partida como abandonada (salir sin terminar).
  Future<void> abandonGame(int sessionId);

  /// Tabla de líderes por juego.
  Future<GameLeaderboardEntity> getLeaderboard(String gameCode);
}
