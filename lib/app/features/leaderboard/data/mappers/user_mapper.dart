import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_user_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';

class UserMapper {
  /// HTTP: respuesta de `POST /listUsers` ya parseada en DTO.
  static List<UserDivisionEntity> fromDto(GetUserListResponseDto dto) {
    return dto.data.userList
        .map(
          (u) => UserDivisionEntity(
            id: u.id,
            name: u.name,
            score: u.score,
            timesRankedFirst: u.timesRankedFirst,
            flag: u.flag,
          ),
        )
        .toList();
  }

  /// WebSocket: payload en vivo (`{ users: { userList: [...] } }`).
  static List<UserDivisionEntity> fromSocketData(Map<String, dynamic> data) {
    final users = data['users'] ?? {};

    return (users['userList'] as List<dynamic>? ?? []).map((u) {
      return UserDivisionEntity(
        id: u['id'] ?? 0,
        name: u['name'] ?? '',
        score: u['score'] ?? 0,
        timesRankedFirst: u['times_ranked_first'] ?? 0,
        flag: u['flag'] ?? '',
      );
    }).toList();
  }
}
