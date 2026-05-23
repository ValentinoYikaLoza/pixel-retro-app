import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/user_mapper.dart';

void main() {
  group('UserMapper.fromSocketData', () {
    test('maps the user list from the socket payload', () {
      final data = {
        'users': {
          'userList': [
            {
              'id': 1,
              'name': 'Ana',
              'score': 100,
              'times_ranked_first': 2,
              'flag': 'pe',
            },
            {
              'id': 2,
              'name': 'Beto',
              'score': 50,
              'times_ranked_first': 0,
              'flag': 'ar',
            },
          ],
        },
      };

      final users = UserMapper.fromSocketData(data);

      expect(users, hasLength(2));
      expect(users.first.id, 1);
      expect(users.first.name, 'Ana');
      expect(users.first.score, 100);
      expect(users.first.timesRankedFirst, 2);
      expect(users.first.flag, 'pe');
    });

    test('returns an empty list when there are no users', () {
      expect(UserMapper.fromSocketData(const {}), isEmpty);
      expect(UserMapper.fromSocketData(const {'users': {}}), isEmpty);
    });

    test('applies safe defaults for missing fields', () {
      final data = {
        'users': {
          'userList': [
            {'id': 3},
          ],
        },
      };

      final user = UserMapper.fromSocketData(data).single;

      expect(user.id, 3);
      expect(user.name, '');
      expect(user.score, 0);
      expect(user.timesRankedFirst, 0);
      expect(user.flag, '');
    });
  });
}
