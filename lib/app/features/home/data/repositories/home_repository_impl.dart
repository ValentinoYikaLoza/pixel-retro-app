import 'package:pixel_retro_app/app/features/home/domain/datasources/home_datasource.dart';
import 'package:pixel_retro_app/app/features/home/domain/models/get_game_list_response_model.dart';
import 'package:pixel_retro_app/app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;

  HomeRepositoryImpl(this.dataSource);

  @override
  Future<GetGameListResponseModel> getGames() {
    return dataSource.getGames();
  }
}
