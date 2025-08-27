import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/time_entity.dart';
import 'package:pixel_retro_app/app/features/reward/domain/datasources/reward_datasource.dart';
import 'package:pixel_retro_app/app/features/reward/domain/entities/reward_entity.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/get_reward_list_response_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/get_time_left_list_response_model.dart';
import 'package:pixel_retro_app/app/features/reward/domain/models/update_progress_request_model.dart';

class RewardDataSourceImpl implements RewardDataSource {
  @override
  Future<GetRewardListResponseModel> getRewards() {
    return Future.delayed(Duration(seconds: 2), () {
      return GetRewardListResponseModel(
        monthlyReward: RewardEntity(
          id: '1',
          description: 'Obtén 20000 puntos en todos los modos',
          typeId: 1,
          categoryId: 1,
          isClaimed: false,
          currentPoints: 0,
          totalPoints: 2000,
        ),
        weeklyReward: RewardEntity(
          id: '2',
          description: 'Obtén 1000 puntos en Tetris Game',
          typeId: 2,
          categoryId: 1,
          isClaimed: false,
          currentPoints: 0,
          totalPoints: 1000,
        ),
        dailyRewards: [
          RewardEntity(
            id: '3',
            description: 'Obtén 20 puntos en Snake Game',
            typeId: 3,
            categoryId: 1,
            isClaimed: false,
            currentPoints: 0,
            totalPoints: 20,
          ),
          RewardEntity(
            id: '4',
            description: 'Obtén 50 puntos en Tetris Game',
            typeId: 3,
            categoryId: 2,
            isClaimed: false,
            currentPoints: 0,
            totalPoints: 50,
          ),
          RewardEntity(
            id: '5',
            description: 'Obtén 100 puntos en Tetris Game',
            typeId: 3,
            categoryId: 3,
            isClaimed: false,
            currentPoints: 0,
            totalPoints: 100,
          ),
        ],
      );
    });
  }

  @override
  Future<void> updateProgress(UpdateProgressRequestModel request) {
    return Future.delayed(Duration(seconds: 2), () {
      return;
    });
  }

  @override
  Future<GetTimeLeftListResponseModel> getTimeLeftList() {
    return Future.delayed(Duration(seconds: 2), () {
      return GetTimeLeftListResponseModel(
        timeLeftList: [
          TimeEntity(time: 5, unit: 'DÍAS'),
          TimeEntity(time: 2, unit: 'HORAS'),
          TimeEntity(time: 45, unit: 'MINUTOS'),
        ],
      );
    });
  }

  @override
  Future<String> getCurrentMonth() {
    return Future.delayed(Duration(seconds: 2), () {
      return 'AGOSTO';
    });
  }
}
