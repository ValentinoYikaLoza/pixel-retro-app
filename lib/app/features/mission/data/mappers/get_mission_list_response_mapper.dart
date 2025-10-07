import 'package:pixel_retro_app/app/features/mission/data/dtos/get_mission_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_mission_list_response_model.dart';

class GetMissionListResponseMapper {
  static GetMissionListResponseModel fromDtoToModel(
    GetMissionListResponseDto response,
  ) {
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

    return GetMissionListResponseModel(
      dailyRewards: response.data.dailyMissions.map((mission) {
        return MissionEntity(
          id: mission.id,
          description: mission.description,
          category: rewardCategoryMap[mission.rewardId]!,
          isClaimed: rewardStateMap[mission.statusId]!,
          currentPoints: mission.currentValue,
          totalPoints: mission.totalValue,
        );
      }).toList(),
      weeklyReward: MissionEntity(
        id: response.data.weeklyMissions[0].id,
        description: response.data.weeklyMissions[0].description,
        category: rewardCategoryMap[response.data.weeklyMissions[0].rewardId]!,
        isClaimed: rewardStateMap[response.data.weeklyMissions[0].statusId]!,
        currentPoints: response.data.weeklyMissions[0].currentValue,
        totalPoints: response.data.weeklyMissions[0].totalValue,
      ),
      monthlyReward: MissionEntity(
        id: response.data.monthlyMissions[0].id,
        description: response.data.monthlyMissions[0].description,
        category: rewardCategoryMap[response.data.monthlyMissions[0].rewardId]!,
        isClaimed: rewardStateMap[response.data.monthlyMissions[0].statusId]!,
        currentPoints: response.data.monthlyMissions[0].currentValue,
        totalPoints: response.data.monthlyMissions[0].totalValue,
      ),
    );
  }
}
