import 'package:pixel_retro_app/app/features/reward/domain/datasources/reward_datasource.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/get_reward_list_response_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/get_time_left_list_response_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/update_progress_request_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/repositories/reward_repository.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardDataSource dataSource;

  RewardRepositoryImpl(this.dataSource);

  @override
  Future<GetRewardListResponseModel> getRewards() {
    return dataSource.getRewards();
  }

  @override
  Future<void> updateProgress(UpdateProgressRequestModel request) {
    return dataSource.updateProgress(request);
  }

  @override
  Future<GetTimeLeftListResponseModel> getTimeLeftList() {
    return dataSource.getTimeLeftList();
  }

  @override
  Future<String> getCurrentMonth() {
    return dataSource.getCurrentMonth();
  }
}
