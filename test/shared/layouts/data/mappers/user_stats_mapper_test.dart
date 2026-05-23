import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/dtos/get_user_response_dto.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/mappers/user_stats_mapper.dart';

void main() {
  group('UserStatsMapper', () {
    test('fromDto parses the HTTP user payload', () {
      final dto = GetUserResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': {
          'id': 7,
          'coins': 120,
          'lives': 3,
          'streak': 9,
          'division_id': 2,
        },
      });

      final stats = UserStatsMapper.fromDto(dto);

      expect(stats.userId, 7);
      expect(stats.coins, 120);
      expect(stats.lives, 3);
      expect(stats.streak, 9);
      expect(stats.divisionId, 2);
    });

    test('fromSocketData reads the nested user object', () {
      final stats = UserStatsMapper.fromSocketData({
        'user': {'id': 1, 'coins': 50},
      });

      expect(stats.userId, 1);
      expect(stats.coins, 50);
      // Campos ausentes quedan en null (el estado conserva su valor).
      expect(stats.lives, isNull);
    });

    test('is null-safe with an empty payload', () {
      final stats = UserStatsMapper.fromDto(
        GetUserResponseDto.fromJson(const {}),
      );
      expect(stats.userId, isNull);
      expect(stats.coins, isNull);
    });
  });
}
