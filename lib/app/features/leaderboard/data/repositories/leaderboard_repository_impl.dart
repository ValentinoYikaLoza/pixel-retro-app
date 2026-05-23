import 'package:pixel_retro_app/app/features/leaderboard/domain/datasources/leaderboard_datasource.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardDatasource datasource;

  LeaderboardRepositoryImpl(this.datasource);

  /// Las divisiones son casi estáticas: se cachean en memoria por sesión.
  /// Los usuarios NO se cachean (ranking en vivo vía WebSocket).
  List<DivisionEntity>? _divisionsCache;

  @override
  Future<List<UserDivisionEntity>> getUsers({int? limit}) {
    return datasource.getUsers(limit: limit);
  }

  @override
  Future<List<DivisionEntity>> getDivisions() async {
    final cached = _divisionsCache;
    if (cached != null) return cached;

    final divisions = await datasource.getDivisions();
    _divisionsCache = divisions;
    return divisions;
  }

  @override
  void clearCache() => _divisionsCache = null;
}
