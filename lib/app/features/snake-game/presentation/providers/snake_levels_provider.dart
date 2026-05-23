import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_level_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/repositories/snake_game_repository.dart';
import 'package:pixel_retro_app/di.dart';

/// Niveles del Snake con el progreso del usuario (mejor puntaje, superado,
/// desbloqueado). Se recarga al re-entrar al selector.
final snakeLevelsProvider = FutureProvider.autoDispose<List<GameLevelEntity>>((
  ref,
) async {
  return getIt<SnakeGameRepository>().listLevels('snake');
});
