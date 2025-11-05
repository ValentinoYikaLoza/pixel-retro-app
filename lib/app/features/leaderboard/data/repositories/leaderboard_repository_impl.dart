import 'package:pixel_retro_app/app/features/leaderboard/domain/datasources/leaderboard_datasource.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardDatasource datasource;

  LeaderboardRepositoryImpl(this.datasource);

  @override
  Future<void> getUsers() {
    return datasource.getUsers();
  }

  @override
  Future<GetDivisionListResponseModel> getDivisions() {
    return datasource.getDivisions();
  }
}
