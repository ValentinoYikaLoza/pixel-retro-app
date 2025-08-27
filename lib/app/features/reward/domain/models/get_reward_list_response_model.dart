import 'package:pixel_retro_app/app/features/reward/domain/entities/reward_entity.dart';

class GetRewardListResponseModel {
  final RewardEntity monthlyReward;
  final RewardEntity weeklyReward;
  final List<RewardEntity> dailyRewards;

  GetRewardListResponseModel({
    required this.monthlyReward,
    required this.weeklyReward,
    required this.dailyRewards,
  });
}
