import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';

class GetGameListResponseModel {
  final List<GameEntity> games;

  GetGameListResponseModel({required this.games});
}
