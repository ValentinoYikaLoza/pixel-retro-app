import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/mission/data/mappers/mission_mapper.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';

void main() {
  group('MissionMapper.fromSocketData', () {
    test('maps daily/weekly/monthly missions and their reward states', () {
      final data = {
        'missions': {
          'dailyMissions': [
            {
              'id': 1,
              'description': 'Win a game',
              'reward_id': 1,
              'status_id': 3,
              'current_value': 5,
              'total_value': 10,
            },
          ],
          'weeklyMissions': [
            {
              'id': 2,
              'description': 'Weekly goal',
              'reward_id': 2,
              'status_id': 1,
              'current_value': 0,
              'total_value': 7,
            },
          ],
          'monthlyMissions': [
            {
              'id': 3,
              'description': 'Monthly goal',
              'reward_id': 3,
              'status_id': 4,
              'current_value': 1,
              'total_value': 30,
            },
          ],
        },
      };

      final model = MissionMapper.fromSocketData(data);

      expect(model.dailyRewards, hasLength(1));
      expect(model.dailyRewards.first.category, RewardCategory.bronzeChest);
      expect(model.dailyRewards.first.isClaimed, RewardState.claimed);

      expect(model.weeklyReward.category, RewardCategory.silverChest);
      expect(model.weeklyReward.isClaimed, RewardState.unclaimed);

      expect(model.monthlyReward.category, RewardCategory.goldChest);
      expect(model.monthlyReward.isClaimed, RewardState.claimed);
    });

    test('falls back to an empty mission when a section is missing', () {
      final model = MissionMapper.fromSocketData(const {});

      expect(model.dailyRewards, isEmpty);
      expect(model.weeklyReward.description, 'Sin datos');
      expect(model.monthlyReward.description, 'Sin datos');
    });
  });
}
