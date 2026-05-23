import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_user_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/user_mapper.dart';

void main() {
  group('UserMapper.fromDto (HTTP)', () {
    test('parses the DTO into ranked users', () {
      final dto = GetUserListResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': {
          'userList': [
            {
              'id': 1,
              'name': 'Ana',
              'score': 100,
              'times_ranked_first': 2,
              'flag': 'pe',
            },
          ],
        },
      });

      final users = UserMapper.fromDto(dto);

      expect(users, hasLength(1));
      expect(users.first.name, 'Ana');
      expect(users.first.score, 100);
      expect(users.first.timesRankedFirst, 2);
    });

    test('is null-safe with an empty/unknown payload', () {
      final users = UserMapper.fromDto(
        GetUserListResponseDto.fromJson(const {}),
      );
      expect(users, isEmpty);
    });
  });
}
