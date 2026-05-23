/// Respuesta de `POST /finishGame`.
/// Forma: `{ success, message, data: { is_high_score, high_score, exp_gained,
/// coins_gained } }`. Parseo defensivo.
class FinishGameResponseDto {
  final bool success;
  final String message;
  final FinishGameDataDto data;

  FinishGameResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FinishGameResponseDto.fromJson(Map<String, dynamic> json) {
    return FinishGameResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: FinishGameDataDto.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class FinishGameDataDto {
  final bool isHighScore;
  final int highScore;
  final int expGained;
  final int coinsGained;
  final bool levelCleared;
  final bool unlockedNext;

  FinishGameDataDto({
    required this.isHighScore,
    required this.highScore,
    required this.expGained,
    required this.coinsGained,
    required this.levelCleared,
    required this.unlockedNext,
  });

  factory FinishGameDataDto.fromJson(Map<String, dynamic> json) {
    return FinishGameDataDto(
      isHighScore: json['is_high_score'] as bool? ?? false,
      highScore: (json['high_score'] as num?)?.toInt() ?? 0,
      expGained: (json['exp_gained'] as num?)?.toInt() ?? 0,
      coinsGained: (json['coins_gained'] as num?)?.toInt() ?? 0,
      levelCleared: json['level_cleared'] as bool? ?? false,
      unlockedNext: json['unlocked_next'] as bool? ?? false,
    );
  }
}
