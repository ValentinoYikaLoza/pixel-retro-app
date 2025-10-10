import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_mission_list_response_model.dart';

class MissionMapper {
  static GetMissionListResponseModel fromSocketData(Map<String, dynamic> data) {
    final missions = data['missions'] ?? {};

    final dailyList = (missions['dailyMissions'] as List<dynamic>? ?? [])
        .map((m) => _mapToMission(m))
        .toList();

    final weeklyList = (missions['weeklyMissions'] as List<dynamic>? ?? [])
        .map((m) => _mapToMission(m))
        .toList();

    final monthlyList = (missions['monthlyMissions'] as List<dynamic>? ?? [])
        .map((m) => _mapToMission(m))
        .toList();

    return GetMissionListResponseModel(
      dailyRewards: dailyList,
      weeklyReward: weeklyList.isNotEmpty ? weeklyList.first : _emptyMission(),
      monthlyReward: monthlyList.isNotEmpty
          ? monthlyList.first
          : _emptyMission(),
    );
  }

  static MissionEntity _mapToMission(Map<String, dynamic> m) {
    final rewardCategoryMap = {
      1: RewardCategory.bronzeChest,
      2: RewardCategory.silverChest,
      3: RewardCategory.goldChest,
    };

    final rewardStateMap = {
      1: RewardState.unclaimed,
      2: RewardState.unclaimed,
      3: RewardState.claimed,
      4: RewardState.claimed,
    };

    return MissionEntity(
      id: m['id'] ?? 0,
      description: m['description'] ?? '',
      category: rewardCategoryMap[m['reward_id']] ?? RewardCategory.bronzeChest,
      isClaimed: rewardStateMap[m['status_id']] ?? RewardState.unclaimed,
      currentPoints: m['current_value'] ?? 0,
      totalPoints: m['total_value'] ?? 0,
    );
  }

  static MissionEntity _emptyMission() {
    return MissionEntity(
      id: 0,
      description: 'Sin datos',
      category: RewardCategory.bronzeChest,
      isClaimed: RewardState.unclaimed,
      currentPoints: 0,
      totalPoints: 0,
    );
  }
}
