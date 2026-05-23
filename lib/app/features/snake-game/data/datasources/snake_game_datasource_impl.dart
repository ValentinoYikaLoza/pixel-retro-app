import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/config/constants/api_endpoints.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/double_game_reward_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/finish_game_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/game_leaderboard_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/game_levels_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/start_game_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_leaderboard_mapper.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_levels_mapper.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_result_mapper.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_session_mapper.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/datasources/snake_game_datasource.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_leaderboard_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_session_entity.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/app/shared/services/session_service.dart';

class SnakeGameDataSourceImpl implements SnakeGameDataSource {
  SnakeGameDataSourceImpl(this._api, this._session);

  final Api _api;
  final SessionService _session;

  @override
  Future<List<GameLevelEntity>> listLevels(String gameCode) async {
    try {
      final formData = {'user_id': _session.userId, 'game_code': gameCode};
      final response = await _api.post(
        ApiEndpoints.listGameLevels,
        data: formData,
      );
      final dto = GameLevelsResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return GameLevelsMapper.fromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener los niveles',
      );
    }
  }

  @override
  Future<GameSessionEntity> startGame(String gameCode, int level) async {
    try {
      final formData = {
        'user_id': _session.userId,
        'game_code': gameCode,
        'level': '$level',
      };
      final response = await _api.post(ApiEndpoints.startGame, data: formData);
      final dto = StartGameResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return GameSessionMapper.fromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al iniciar la partida',
      );
    }
  }

  @override
  Future<GameResultEntity> finishGame({
    required int sessionId,
    required int score,
    required int foodEaten,
    required int durationMs,
  }) async {
    try {
      final formData = {
        'user_id': _session.userId,
        'session_id': '$sessionId',
        'score': '$score',
        'food_eaten': '$foodEaten',
        'duration_ms': '$durationMs',
      };
      final response = await _api.post(ApiEndpoints.finishGame, data: formData);
      final dto = FinishGameResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return GameResultMapper.fromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al finalizar la partida',
      );
    }
  }

  @override
  Future<int> doubleReward(int sessionId) async {
    try {
      final formData = {'user_id': _session.userId, 'session_id': '$sessionId'};
      final response = await _api.post(
        ApiEndpoints.doubleGameReward,
        data: formData,
      );
      final dto = DoubleGameRewardResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return dto.expGained;
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al duplicar la recompensa',
      );
    }
  }

  @override
  Future<void> abandonGame(int sessionId) async {
    try {
      final formData = {'user_id': _session.userId, 'session_id': '$sessionId'};
      await _api.post(ApiEndpoints.abandonGame, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al abandonar la partida',
      );
    }
  }

  @override
  Future<GameLeaderboardEntity> getLeaderboard(String gameCode) async {
    try {
      final formData = {'user_id': _session.userId, 'game_code': gameCode};
      final response = await _api.post(
        ApiEndpoints.getGameLeaderboard,
        data: formData,
      );
      final dto = GameLeaderboardResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return GameLeaderboardMapper.fromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al obtener el leaderboard',
      );
    }
  }
}
