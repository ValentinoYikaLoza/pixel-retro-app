import 'package:pixel_retro_app/app/features/home/domain/models/get_game_list_response_model.dart';

abstract class HomeRepository {
  Future<GetGameListResponseModel> getGames();
}
