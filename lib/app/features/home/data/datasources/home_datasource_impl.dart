import 'package:pixel_retro_app/app/features/home/domain/datasources/home_datasource.dart';
import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';
import 'package:pixel_retro_app/app/features/home/domain/models/get_game_list_response_model.dart';

class HomeDataSourceImpl implements HomeDataSource {
  @override
  Future<GetGameListResponseModel> getGamesData() {
    return Future.delayed(Duration(milliseconds: 200), () {
      return GetGameListResponseModel(
        games: [
          GameEntity(id: 1, name: 'snake', title: 'Snake'),
          GameEntity(id: 2, name: 'tetris', title: 'Tetris'),
          GameEntity(id: 3, name: 'invader', title: 'Pixel Invader'),
          GameEntity(id: 4, name: 'pacman', title: 'Pacman'),
        ],
      );
    });
  }
}
