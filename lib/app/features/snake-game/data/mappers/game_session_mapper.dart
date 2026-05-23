import 'dart:ui' show Offset;

import 'package:pixel_retro_app/app/features/snake-game/data/dtos/start_game_response_dto.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_session_entity.dart';

class GameSessionMapper {
  static GameSessionEntity fromDto(StartGameResponseDto dto) {
    return GameSessionEntity(
      sessionId: dto.data.sessionId,
      level: dto.data.level,
      seed: dto.data.seed,
      tickMs: dto.data.tickMs,
      gridWidth: dto.data.gridWidth,
      gridHeight: dto.data.gridHeight,
      wrapAround: dto.data.wrapAround,
      walls: wallsToOffsets(dto.data.walls),
      targetScore: dto.data.targetScore,
      livesLeft: dto.data.livesLeft,
    );
  }
}

/// Convierte la lista de pares `[x, y]` en celdas [Offset] del tablero.
List<Offset> wallsToOffsets(List<List<int>> walls) {
  return walls
      .map((c) => Offset(c[0].toDouble(), c[1].toDouble()))
      .toList(growable: false);
}
