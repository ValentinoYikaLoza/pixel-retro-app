import 'package:pixel_retro_app/app/features/mission/domain/entities/missions_board_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/update_progress_request_model.dart';

abstract class MissionDataSource {
  Future<MissionsBoardEntity> getMissions();
  Future<void> updateProgress(UpdateProgressRequestModel request);
}
