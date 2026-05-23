import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/home/data/dtos/get_game_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/home/data/mappers/game_mapper.dart';

void main() {
  group('GameMapper.fromDto', () {
    test('maps games and filters out disabled ones', () {
      final dto = GetGameListResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': [
          {'id': 1, 'code': 'snake', 'title': 'Snake', 'enabled': true},
          {'id': 2, 'code': 'tetris', 'title': 'Tetris', 'enabled': false},
        ],
      });

      final games = GameMapper.fromDto(dto);

      expect(games, hasLength(1));
      expect(games.first.code, 'snake');
      expect(games.first.title, 'Snake');
    });

    test('is null-safe with an empty payload', () {
      expect(
        GameMapper.fromDto(GetGameListResponseDto.fromJson(const {})),
        isEmpty,
      );
    });
  });
}
