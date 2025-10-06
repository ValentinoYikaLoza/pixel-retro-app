import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_user_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_user_list_response_model.dart';

class GetUserListResponseMapper {
  static GetUserListResponseModel fromDtoToModel(GetUserListResponseDto dto) {
    return GetUserListResponseModel(
      users: dto.data.map((user) {
        return UserDivisionEntity(
          id: user.id,
          name: user.name,
          score: user.score,
          timesRankedFirst: user.timesRankedFirst,
          flag: user.flag,
        );
      }).toList(),
    );
  }
}
