/// Respuesta de `POST /startGame`.
/// Forma: `{ success, message, data: { session_id, level, seed, tick_ms,
/// grid_width, grid_height, wrap_around, walls, target_score, lives_left } }`.
/// Parseo defensivo.
class StartGameResponseDto {
  final bool success;
  final String message;
  final StartGameDataDto data;

  StartGameResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StartGameResponseDto.fromJson(Map<String, dynamic> json) {
    return StartGameResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: StartGameDataDto.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class StartGameDataDto {
  final int sessionId;
  final int level;
  final int seed;
  final int tickMs;
  final int gridWidth;
  final int gridHeight;
  final bool wrapAround;
  final List<List<int>> walls;
  final int targetScore;
  final int livesLeft;

  StartGameDataDto({
    required this.sessionId,
    required this.level,
    required this.seed,
    required this.tickMs,
    required this.gridWidth,
    required this.gridHeight,
    required this.wrapAround,
    required this.walls,
    required this.targetScore,
    required this.livesLeft,
  });

  factory StartGameDataDto.fromJson(Map<String, dynamic> json) {
    return StartGameDataDto(
      sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      tickMs: (json['tick_ms'] as num?)?.toInt() ?? 200,
      gridWidth: (json['grid_width'] as num?)?.toInt() ?? 30,
      gridHeight: (json['grid_height'] as num?)?.toInt() ?? 20,
      wrapAround: json['wrap_around'] as bool? ?? true,
      walls: parseWalls(json['walls']),
      targetScore: (json['target_score'] as num?)?.toInt() ?? 0,
      livesLeft: (json['lives_left'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Convierte `[[x,y], ...]` (JSON) en una lista de pares int, de forma robusta.
List<List<int>> parseWalls(dynamic raw) {
  if (raw is! List) return const [];
  final result = <List<int>>[];
  for (final cell in raw) {
    if (cell is List && cell.length >= 2) {
      final x = (cell[0] as num?)?.toInt() ?? 0;
      final y = (cell[1] as num?)?.toInt() ?? 0;
      result.add([x, y]);
    }
  }
  return result;
}
