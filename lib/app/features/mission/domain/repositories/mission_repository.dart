import 'package:pixel_retro_app/app/features/mission/domain/models/get_mission_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_time_left_list_response_model.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/update_progress_request_model.dart';

abstract class MissionRepository {
  Future<GetMissionListResponseModel> getMissions();
  Future<void> updateProgress(UpdateProgressRequestModel request);
  Future<GetTimeLeftListResponseModel> getTimeLeftList();
  Future<String> getCurrentMonth();
}
