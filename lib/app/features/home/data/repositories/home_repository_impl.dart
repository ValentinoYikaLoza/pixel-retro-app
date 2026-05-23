import 'package:pixel_retro_app/app/features/home/domain/datasources/home_datasource.dart';
import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';
import 'package:pixel_retro_app/app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;

  HomeRepositoryImpl(this.dataSource);

  /// Los juegos son casi estáticos: se cachean en memoria por sesión.
  List<GameEntity>? _gamesCache;

  @override
  Future<List<GameEntity>> getGames() async {
    final cached = _gamesCache;
    if (cached != null) return cached;

    final games = await dataSource.getGames();
    _gamesCache = games;
    return games;
  }

  @override
  void clearCache() => _gamesCache = null;
}
