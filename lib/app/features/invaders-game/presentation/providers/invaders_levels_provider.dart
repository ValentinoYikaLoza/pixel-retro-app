import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/repositories/snake_game_repository.dart';
import 'package:pixel_retro_app/di.dart';

/// Niveles de Pixel Invaders con el progreso del usuario. Reusa el repositorio
/// de sesión de juego (genérico por código de juego).
final invadersLevelsProvider =
    FutureProvider.autoDispose<List<GameLevelEntity>>((ref) async {
      return getIt<SnakeGameRepository>().listLevels('invaders');
    });
