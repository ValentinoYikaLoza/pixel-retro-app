import 'package:pixel_retro_app/app/features/mission/domain/datasources/mission_datasource.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_mission_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_time_left_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/update_progress_request_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/repositories/mission_repository.dart';

class MissionRepositoryImpl implements MissionRepository {
  final MissionDataSource dataSource;

  MissionRepositoryImpl(this.dataSource);

  @override
  Future<GetMissionListResponseModel> getMissions() {
    return dataSource.getMissions();
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
