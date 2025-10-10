import 'package:pixel_retro_app/app/features/mission/domain/models/update_progress_request_model.dart';

abstract class MissionRepository {
  Future<void> getMissions();
  Future<void> updateProgress(UpdateProgressRequestModel request);
}
