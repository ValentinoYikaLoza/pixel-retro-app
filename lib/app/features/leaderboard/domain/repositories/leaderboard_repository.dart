import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';

abstract class LeaderboardRepository {
  /// [limit]: máximo de usuarios a traer (acota el payload del ranking).
  /// Si es `null` se usa el tamaño por defecto del datasource.
  Future<List<UserDivisionEntity>> getUsers({int? limit});
  Future<List<DivisionEntity>> getDivisions();

  /// Limpia la caché en memoria (forzar recarga desde red).
  void clearCache();
}
