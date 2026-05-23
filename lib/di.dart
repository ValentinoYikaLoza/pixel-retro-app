import 'package:get_it/get_it.dart';
import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/shared/services/session_service.dart';
import 'package:pixel_retro_app/app/features/home/data/datasources/home_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/home/data/repositories/home_repository_impl.dart';
import 'package:pixel_retro_app/app/features/home/domain/datasources/home_datasource.dart';
import 'package:pixel_retro_app/app/features/home/domain/repositories/home_repository.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/datasources/leaderboard_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/datasources/leaderboard_datasource.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:pixel_retro_app/app/features/mission/data/datasources/mission_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/mission/data/repositories/mission_repository_impl.dart';
import 'package:pixel_retro_app/app/features/mission/domain/datasources/mission_datasource.dart';
import 'package:pixel_retro_app/app/features/mission/domain/repositories/mission_repository.dart';
import 'package:pixel_retro_app/app/features/shop/data/datasources/shop_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:pixel_retro_app/app/features/shop/domain/datasources/shop_datasource.dart';
import 'package:pixel_retro_app/app/features/shop/domain/repositories/shop_repository.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/datasources/snake_game_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/snake-game/data/repositories/snake_game_repository_impl.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/datasources/snake_game_datasource.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/repositories/snake_game_repository.dart';
import 'package:pixel_retro_app/app/features/time/data/datasources/time_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/time/data/repositories/time_repository_impl.dart';
import 'package:pixel_retro_app/app/features/time/domain/datasources/time_datasource.dart';
import 'package:pixel_retro_app/app/features/time/domain/repositories/time_repository.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/datasources/user_datasource_impl.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/repositories/user_repository_impl.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/datasources/user_datasource.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/repositories/user_repository.dart';

final getIt = GetIt.instance;

void setup({required String userId}) {
  // Session (current user) + HTTP client (single Dio shared across the app)
  getIt.registerLazySingleton<SessionService>(
    () => SessionService(userId: userId),
  );
  getIt.registerLazySingleton<Api>(() => Api());

  // Data sources
  getIt.registerLazySingleton<UserDataSource>(
    () => UserDataSourceImpl(getIt<Api>(), getIt<SessionService>()),
  );
  getIt.registerLazySingleton<HomeDataSource>(
    () => HomeDataSourceImpl(getIt<Api>()),
  );
  getIt.registerLazySingleton<LeaderboardDatasource>(
    () => LeaderboardDatasourceImpl(getIt<Api>(), getIt<SessionService>()),
  );
  getIt.registerLazySingleton<MissionDataSource>(
    () => MissionDataSourceImpl(getIt<Api>(), getIt<SessionService>()),
  );
  getIt.registerLazySingleton<ShopDatasource>(
    () => ShopDatasourceImpl(getIt<Api>(), getIt<SessionService>()),
  );
  getIt.registerLazySingleton<TimeDataSource>(
    () => TimeDataSourceImpl(getIt<Api>()),
  );
  getIt.registerLazySingleton<SnakeGameDataSource>(
    () => SnakeGameDataSourceImpl(getIt<Api>(), getIt<SessionService>()),
  );

  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserDataSource>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<HomeDataSource>()),
  );
  getIt.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(getIt<LeaderboardDatasource>()),
  );
  getIt.registerLazySingleton<MissionRepository>(
    () => MissionRepositoryImpl(getIt<MissionDataSource>()),
  );
  getIt.registerLazySingleton<TimeRepository>(
    () => TimeRepositoryImpl(getIt<TimeDataSource>()),
  );
  getIt.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(getIt<ShopDatasource>()),
  );
  getIt.registerLazySingleton<SnakeGameRepository>(
    () => SnakeGameRepositoryImpl(getIt<SnakeGameDataSource>()),
  );
}
