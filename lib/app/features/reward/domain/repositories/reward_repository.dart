import 'package:pixel_retro_app/app/features/reward/domain/models/get_reward_list_response_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/get_time_left_list_response_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/update_progress_request_model.dart';

abstract class RewardRepository {
  Future<GetRewardListResponseModel> getRewards();
  Future<void> updateProgress(UpdateProgressRequestModel request);
  Future<GetTimeLeftListResponseModel> getTimeLeftList();
  Future<String> getCurrentMonth();
}
