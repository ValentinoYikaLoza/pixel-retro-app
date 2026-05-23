import 'package:pixel_retro_app/app/features/snake-game/data/dtos/start_game_response_dto.dart'
    show parseWalls;

/// Respuesta de `POST /listGameLevels`.
/// Forma: `{ success, message, data: { levels: [{ level, tick_ms, grid_width,
/// grid_height, wrap_around, walls, target_score, best_score, cleared,
/// unlocked }] } }`. Parseo defensivo.
class GameLevelsResponseDto {
  final bool success;
  final String message;
  final List<GameLevelDto> levels;

  GameLevelsResponseDto({
    required this.success,
    required this.message,
    required this.levels,
  });

  factory GameLevelsResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return GameLevelsResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      levels: (data['levels'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                GameLevelDto.fromJson(e as Map<String, dynamic>? ?? const {}),
          )
          .toList(),
    );
  }
}

class GameLevelDto {
  final int level;
  final int tickMs;
  final int gridWidth;
  final int gridHeight;
  final bool wrapAround;
  final List<List<int>> walls;
  final int targetScore;
  final int bestScore;
  final bool cleared;
  final bool unlocked;

  GameLevelDto({
    required this.level,
    required this.tickMs,
    required this.gridWidth,
    required this.gridHeight,
    required this.wrapAround,
    required this.walls,
    required this.targetScore,
    required this.bestScore,
    required this.cleared,
    required this.unlocked,
  });

  factory GameLevelDto.fromJson(Map<String, dynamic> json) {
    return GameLevelDto(
      level: (json['level'] as num?)?.toInt() ?? 1,
      tickMs: (json['tick_ms'] as num?)?.toInt() ?? 200,
      gridWidth: (json['grid_width'] as num?)?.toInt() ?? 30,
      gridHeight: (json['grid_height'] as num?)?.toInt() ?? 20,
      wrapAround: json['wrap_around'] as bool? ?? true,
      walls: parseWalls(json['walls']),
      targetScore: (json['target_score'] as num?)?.toInt() ?? 0,
      bestScore: (json['best_score'] as num?)?.toInt() ?? 0,
      cleared: json['cleared'] as bool? ?? false,
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }
}
