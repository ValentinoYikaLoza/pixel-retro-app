import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/finish_game_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/game_leaderboard_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/start_game_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_leaderboard_mapper.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_result_mapper.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_session_mapper.dart';

void main() {
  group('GameSessionMapper.fromDto', () {
    test('maps the start payload (seed + config)', () {
      final dto = StartGameResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': {
          'session_id': 7,
          'seed': 5479536641748880612,
          'tick_ms': 200,
          'grid_width': 30,
          'grid_height': 20,
          'lives_left': 99,
        },
      });

      final session = GameSessionMapper.fromDto(dto);

      expect(session.sessionId, 7);
      expect(session.seed, 5479536641748880612);
      expect(session.tickMs, 200);
      expect(session.gridWidth, 30);
      expect(session.gridHeight, 20);
      expect(session.livesLeft, 99);
    });

    test('falls back to safe config defaults with an empty payload', () {
      final session = GameSessionMapper.fromDto(
        StartGameResponseDto.fromJson(const {}),
      );

      expect(session.sessionId, 0);
      expect(session.tickMs, 200);
      expect(session.gridWidth, 30);
      expect(session.gridHeight, 20);
    });
  });

  group('GameResultMapper.fromDto', () {
    test('maps the finish payload (rewards)', () {
      final dto = FinishGameResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': {
          'is_high_score': true,
          'high_score': 120,
          'exp_gained': 120,
          'coins_gained': 12,
        },
      });

      final result = GameResultMapper.fromDto(dto);

      expect(result.isHighScore, isTrue);
      expect(result.highScore, 120);
      expect(result.expGained, 120);
      expect(result.coinsGained, 12);
    });
  });

  group('GameLeaderboardMapper.fromDto', () {
    test('maps entries and the "me" summary', () {
      final dto = GameLeaderboardResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': {
          'leaderboard': [
            {
              'user_id': 1,
              'name': 'Valentino',
              'high_score': 120,
              'total_games': 3,
              'flag': '🇵🇪',
            },
          ],
          'me': {'high_score': 120, 'total_games': 3, 'total_score': 300},
        },
      });

      final board = GameLeaderboardMapper.fromDto(dto);

      expect(board.entries, hasLength(1));
      expect(board.entries.first.name, 'Valentino');
      expect(board.entries.first.highScore, 120);
      expect(board.myHighScore, 120);
      expect(board.myTotalGames, 3);
      expect(board.myTotalScore, 300);
    });

    test('is null-safe with an empty payload', () {
      final board = GameLeaderboardMapper.fromDto(
        GameLeaderboardResponseDto.fromJson(const {}),
      );

      expect(board.entries, isEmpty);
      expect(board.myHighScore, 0);
    });
  });
}
