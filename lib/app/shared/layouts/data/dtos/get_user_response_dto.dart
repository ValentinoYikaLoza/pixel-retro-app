/// Respuesta de `POST /getUser`.
///
/// Forma asumida: `{ success, message, data: { id, coins, lives, streak,
/// division_id } }`. Parseo defensivo (campos opcionales): si el backend anida
/// el usuario bajo otra clave, ajusta `UserDto.fromJson`; mientras tanto los
/// campos faltantes quedan en `null` y el WebSocket sigue actualizando en vivo.
class GetUserResponseDto {
  final bool success;
  final String message;
  final UserDto data;

  GetUserResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetUserResponseDto.fromJson(Map<String, dynamic> json) {
    return GetUserResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: UserDto.fromJson(json['data'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class UserDto {
  final int? id;
  final int? coins;
  final int? lives;
  final int? streak;

  /// True si el check-in diario de hoy subió la racha (para el toast).
  final bool streakIncremented;
  final int? divisionId;

  UserDto({
    this.id,
    this.coins,
    this.lives,
    this.streak,
    this.streakIncremented = false,
    this.divisionId,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int?,
      coins: json['coins'] as int?,
      lives: json['lives'] as int?,
      streak: json['streak'] as int?,
      streakIncremented: json['streak_incremented'] as bool? ?? false,
      divisionId: json['division_id'] as int?,
    );
  }
}
