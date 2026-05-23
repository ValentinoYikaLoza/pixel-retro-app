/// Respuesta de `GET /listGames`.
/// Forma: `{ success, message, data: [{ id, code, title, enabled }] }`.
/// `code` es la clave estable (asset/ruta). `enabled` permite activar/desactivar
/// juegos desde el server. Parseo defensivo.
class GetGameListResponseDto {
  final bool success;
  final String message;
  final List<GameDto> data;

  GetGameListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetGameListResponseDto.fromJson(Map<String, dynamic> json) {
    return GetGameListResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => GameDto.fromJson(e as Map<String, dynamic>? ?? const {}))
          .toList(),
    );
  }
}

class GameDto {
  final int id;
  final String code;
  final String title;
  final bool enabled;

  GameDto({
    required this.id,
    required this.code,
    required this.title,
    required this.enabled,
  });

  factory GameDto.fromJson(Map<String, dynamic> json) {
    return GameDto(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
