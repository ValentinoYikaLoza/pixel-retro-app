import 'package:pixel_retro_app/app/features/mission/domain/entities/missions_board_entity.dart';

abstract class MissionDataSource {
  Future<MissionsBoardEntity> getMissions();
}
