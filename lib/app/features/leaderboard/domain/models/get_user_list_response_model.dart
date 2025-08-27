import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';

class GetUserListResponseModel {
  final List<UserDivisionEntity> users;

  GetUserListResponseModel({required this.users});
}
