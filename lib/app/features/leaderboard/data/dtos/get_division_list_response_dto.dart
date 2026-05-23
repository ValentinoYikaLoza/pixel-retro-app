/// Respuesta de `GET /listDivisions`. Forma: `{ success, message, data: [...] }`.
/// Parseo defensivo: campos faltantes usan valores por defecto.
class GetDivisionListResponseDto {
  final bool success;
  final String message;
  final List<DivisionDto> data;

  GetDivisionListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetDivisionListResponseDto.fromJson(Map<String, dynamic> json) {
    return GetDivisionListResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (e) => DivisionDto.fromJson(e as Map<String, dynamic>? ?? const {}),
          )
          .toList(),
    );
  }
}

class DivisionDto {
  final int id;
  final String name;

  DivisionDto({required this.id, required this.name});

  factory DivisionDto.fromJson(Map<String, dynamic> json) {
    return DivisionDto(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
