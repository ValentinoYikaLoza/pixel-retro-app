import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';

abstract class HomeRepository {
  Future<List<GameEntity>> getGames();

  /// Limpia la caché en memoria (forzar recarga desde red).
  void clearCache();
}
