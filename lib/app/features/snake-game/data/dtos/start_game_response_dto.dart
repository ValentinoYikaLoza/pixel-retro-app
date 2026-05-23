/// Respuesta de `POST /startGame`.
/// Forma: `{ success, message, data: { session_id, seed, tick_ms, grid_width,
/// grid_height, lives_left } }`. Parseo defensivo.
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
  final int seed;
  final int tickMs;
  final int gridWidth;
  final int gridHeight;
  final int livesLeft;

  StartGameDataDto({
    required this.sessionId,
    required this.seed,
    required this.tickMs,
    required this.gridWidth,
    required this.gridHeight,
    required this.livesLeft,
  });

  factory StartGameDataDto.fromJson(Map<String, dynamic> json) {
    return StartGameDataDto(
      sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      tickMs: (json['tick_ms'] as num?)?.toInt() ?? 200,
      gridWidth: (json['grid_width'] as num?)?.toInt() ?? 30,
      gridHeight: (json['grid_height'] as num?)?.toInt() ?? 20,
      livesLeft: (json['lives_left'] as num?)?.toInt() ?? 0,
    );
  }
}
