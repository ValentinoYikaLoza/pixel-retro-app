import 'package:get_it/get_it.dart';
import 'package:pixel_retro_app/app/features/home/data/datasources/home_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/home/data/repositories/home_repository_impl.dart';
import 'package:pixel_retro_app/app/features/home/domain/datasources/home_datasource.dart';
import 'package:pixel_retro_app/app/features/home/domain/repositories/home_repository.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/datasources/leaderboard_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/datasources/leaderboard_datasource.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:pixel_retro_app/app/features/reward/data/datasources/reward_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/reward/data/repositories/reward_repository_impl.dart';
import 'package:pixel_retro_app/app/features/reward/domain/datasources/reward_datasource.dart';
import 'package:pixel_retro_app/app/features/reward/domain/repositories/reward_repository.dart';
import 'package:pixel_retro_app/app/features/shop/data/datasources/shop_datasource_impl.dart';
import 'package:pixel_retro_app/app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:pixel_retro_app/app/features/shop/domain/datasources/shop_datasource.dart';
import 'package:pixel_retro_app/app/features/shop/domain/repositories/shop_repository.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/datasources/user_datasource_impl.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/repositories/user_repository_impl.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/datasources/user_datasource.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/repositories/user_repository.dart';

final getIt = GetIt.instance;

void setup() {
  // Data sources
  getIt.registerLazySingleton<UserDataSource>(() => UserDataSourceImpl());
  getIt.registerLazySingleton<HomeDataSource>(() => HomeDataSourceImpl());
  getIt.registerLazySingleton<LeaderboardDatasource>(
    () => LeaderboardDatasourceImpl(),
  );
  getIt.registerLazySingleton<RewardDataSource>(() => RewardDataSourceImpl());
  getIt.registerLazySingleton<ShopDatasource>(() => ShopDatasourceImpl());

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
  getIt.registerLazySingleton<RewardRepository>(
    () => RewardRepositoryImpl(getIt<RewardDataSource>()),
  );
  getIt.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(getIt<ShopDatasource>()),
  );
}
