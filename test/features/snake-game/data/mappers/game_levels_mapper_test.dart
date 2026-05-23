import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/dtos/game_levels_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/mappers/game_levels_mapper.dart';

void main() {
  group('GameLevelsMapper.fromDto', () {
    test('maps levels, walls and progress flags', () {
      final dto = GameLevelsResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': {
          'levels': [
            {
              'level': 1,
              'tick_ms': 240,
              'grid_width': 30,
              'grid_height': 20,
              'wrap_around': true,
              'walls': [],
              'target_score': 8,
              'best_score': 12,
              'cleared': true,
              'unlocked': true,
            },
            {
              'level': 2,
              'tick_ms': 210,
              'grid_width': 30,
              'grid_height': 20,
              'wrap_around': false,
              'walls': [
                [5, 5],
                [6, 5],
              ],
              'target_score': 15,
              'best_score': 0,
              'cleared': false,
              'unlocked': true,
            },
          ],
        },
      });

      final levels = GameLevelsMapper.fromDto(dto);

      expect(levels, hasLength(2));
      expect(levels.first.level, 1);
      expect(levels.first.wrapAround, isTrue);
      expect(levels.first.cleared, isTrue);
      expect(levels.first.walls, isEmpty);

      final l2 = levels[1];
      expect(l2.wrapAround, isFalse);
      expect(l2.walls, hasLength(2));
      expect(l2.walls.first.dx, 5);
      expect(l2.walls.first.dy, 5);
      expect(l2.unlocked, isTrue);
    });

    test('is null-safe with an empty payload', () {
      final levels = GameLevelsMapper.fromDto(
        GameLevelsResponseDto.fromJson(const {}),
      );
      expect(levels, isEmpty);
    });
  });
}
