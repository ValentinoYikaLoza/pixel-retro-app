import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';

abstract class LeaderboardDatasource {
  Future<List<UserDivisionEntity>> getUsers({int? limit});
  Future<List<DivisionEntity>> getDivisions();
}
