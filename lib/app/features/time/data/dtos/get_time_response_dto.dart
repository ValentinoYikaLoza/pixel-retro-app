/// Respuesta de `GET /getTime`. Forma: `{ success, message, data: { time } }`.
/// Parseo defensivo: una fecha inválida cae a `DateTime.now()` en vez de lanzar.
class GetTimeResponseDto {
  final bool success;
  final String message;
  final TimeData data;

  GetTimeResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetTimeResponseDto.fromJson(Map<String, dynamic> json) {
    return GetTimeResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: TimeData.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class TimeData {
  final DateTime time;

  TimeData({required this.time});

  factory TimeData.fromJson(Map<String, dynamic> json) {
    return TimeData(
      time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
