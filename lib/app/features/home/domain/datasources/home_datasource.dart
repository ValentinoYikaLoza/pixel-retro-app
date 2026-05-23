import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';

abstract class HomeDataSource {
  Future<List<GameEntity>> getGames();
}
