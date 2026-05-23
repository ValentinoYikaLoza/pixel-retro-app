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
    // El backend envía UTC (ISO 8601 Zulu). Normalizamos a UTC: es el instante
    // de referencia; el cliente lo adapta a la zona del usuario al mostrar.
    final parsed = DateTime.tryParse(json['time']?.toString() ?? '');
    return TimeData(time: (parsed ?? DateTime.now()).toUtc());
  }
}
