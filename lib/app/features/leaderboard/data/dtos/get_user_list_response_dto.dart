/// Respuesta de `POST /listUsers`.
///
/// Forma asumida: `{ success, message, data: { userList: [...] } }` (espejo del
/// payload del WebSocket). Parseo defensivo: si el backend usa otra ruta para
/// la lista, ajusta `UserListData.fromJson`; mientras tanto devuelve vacío sin
/// lanzar y el WebSocket sigue alimentando la lista en vivo.
class GetUserListResponseDto {
  final bool success;
  final String message;
  final UserListData data;

  GetUserListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetUserListResponseDto.fromJson(Map<String, dynamic> json) {
    return GetUserListResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: UserListData.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class UserListData {
  final List<UserRankDto> userList;

  UserListData({required this.userList});

  factory UserListData.fromJson(Map<String, dynamic> json) {
    return UserListData(
      userList: (json['userList'] as List<dynamic>? ?? [])
          .map(
            (e) => UserRankDto.fromJson(e as Map<String, dynamic>? ?? const {}),
          )
          .toList(),
    );
  }
}

class UserRankDto {
  final int id;
  final String name;
  final int score;
  final int timesRankedFirst;
  final String flag;

  UserRankDto({
    required this.id,
    required this.name,
    required this.score,
    required this.timesRankedFirst,
    required this.flag,
  });

  factory UserRankDto.fromJson(Map<String, dynamic> json) {
    return UserRankDto(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      score: json['score'] as int? ?? 0,
      timesRankedFirst: json['times_ranked_first'] as int? ?? 0,
      flag: json['flag']?.toString() ?? '',
    );
  }
}
