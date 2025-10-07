import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';

class GetMissionListResponseModel {
  final MissionEntity monthlyReward;
  final MissionEntity weeklyReward;
  final List<MissionEntity> dailyRewards;

  GetMissionListResponseModel({
    required this.monthlyReward,
    required this.weeklyReward,
    required this.dailyRewards,
  });
}
