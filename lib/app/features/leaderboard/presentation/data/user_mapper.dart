import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_user_list_response_model.dart';

class UserMapper {
  static GetUserListResponseModel fromSocketData(Map<String, dynamic> data) {
    final users = data['users'] ?? {};

    final userList = (users['userList'] as List<dynamic>? ?? []).map((u) {
      return UserDivisionEntity(
        id: u['id'] ?? 0,
        name: u['name'] ?? '',
        score: u['score'] ?? 0,
        timesRankedFirst: u['times_ranked_first'] ?? 0,
        flag: u['flag'] ?? '',
      );
    }).toList();

    return GetUserListResponseModel(users: userList);
  }
}
