import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';

abstract class LeaderboardRepository {
  Future<void> getUsers();
  Future<GetDivisionListResponseModel> getDivisions();
}
