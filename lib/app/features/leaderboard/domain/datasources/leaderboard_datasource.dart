import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_current_division_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_current_user_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_time_left_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_user_list_response_model.dart';

abstract class LeaderboardDatasource {
  Future<GetUserListResponseModel> getUsers();
  Future<GetDivisionListResponseModel> getDivisions();
  Future<GetTimeLeftResponseModel> getTimeLeft();
  Future<GetCurrentDivisionResponseModel> getCurrentDivision();
  Future<GetCurrentUserResponseModel> getCurrentUser();
}
