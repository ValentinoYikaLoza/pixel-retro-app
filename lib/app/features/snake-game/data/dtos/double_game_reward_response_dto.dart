/// Respuesta de `POST /doubleGameReward`.
/// Forma: `{ success, message, data: { exp_gained, already_rewarded } }`.
/// Parseo defensivo.
class DoubleGameRewardResponseDto {
  final bool success;
  final String message;
  final int expGained;
  final bool alreadyRewarded;

  DoubleGameRewardResponseDto({
    required this.success,
    required this.message,
    required this.expGained,
    required this.alreadyRewarded,
  });

  factory DoubleGameRewardResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return DoubleGameRewardResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      expGained: (data['exp_gained'] as num?)?.toInt() ?? 0,
      alreadyRewarded: data['already_rewarded'] as bool? ?? false,
    );
  }
}
