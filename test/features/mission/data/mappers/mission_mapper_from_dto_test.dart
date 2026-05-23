import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/mission/data/dtos/get_mission_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/mission/data/mappers/mission_mapper.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';

void main() {
  group('MissionMapper.fromDto (HTTP)', () {
    test('parses the DTO and maps reward/status', () {
      final dto = GetMissionListResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': {
          'dailyMissions': [
            {
              'id': 1,
              'description': 'Win',
              'reward_id': 1,
              'status_id': 3,
              'current_value': 5,
              'total_value': 10,
            },
          ],
          'weeklyMissions': [
            {
              'id': 2,
              'description': 'Weekly',
              'reward_id': 2,
              'status_id': 1,
              'current_value': 0,
              'total_value': 7,
            },
          ],
          'monthlyMissions': <dynamic>[],
        },
      });

      final board = MissionMapper.fromDto(dto);

      expect(board.dailyRewards, hasLength(1));
      expect(board.dailyRewards.first.category, RewardCategory.bronzeChest);
      expect(board.dailyRewards.first.isClaimed, RewardState.claimed);
      expect(board.weeklyReward.category, RewardCategory.silverChest);
      // monthly vacío -> misión por defecto
      expect(board.monthlyReward.description, 'Sin datos');
    });

    test('is null-safe with an empty/unknown payload', () {
      final board = MissionMapper.fromDto(
        GetMissionListResponseDto.fromJson(const {}),
      );

      expect(board.dailyRewards, isEmpty);
      expect(board.weeklyReward.description, 'Sin datos');
      expect(board.monthlyReward.description, 'Sin datos');
    });
  });
}
