import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';
import 'package:pixel_retro_app/app/features/home/domain/models/get_game_list_response_model.dart';
import 'package:pixel_retro_app/app/features/home/domain/repositories/home_repository.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this.ref) : super(HomeState()) {
    _init();
  }

  final Ref ref;
  final HomeRepository repository = getIt<HomeRepository>();

  void _init() {
    ref.listen<bool>(
      internetStatusProvider.select((async) => async.value ?? false),
      (previous, hasInternet) {
        if (!hasInternet) {
          initData();
        }
      },
    );
  }

  void initData() async {
    state = state.copyWith(games: const [], gameSelected: null);
  }

  Future<void> getGames() async {
    try {
      final GetGameListResponseModel response = await repository.getGames();
      state = state.copyWith(
        games: response.games,
        gameSelected: response.games[0],
      );
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo los juegos',
        type: SnackbarType.error,
      );
    }
  }

  void selectGame(String game) {
    final selectedGame = state.games.firstWhere((g) => g.title == game);
    state = state.copyWith(gameSelected: selectedGame);
  }
}

class HomeState {
  final GameEntity? gameSelected;
  final List<GameEntity> games;

  HomeState({this.gameSelected, this.games = const []});

  HomeState copyWith({GameEntity? gameSelected, List<GameEntity>? games}) {
    return HomeState(
      gameSelected: gameSelected ?? this.gameSelected,
      games: games ?? this.games,
    );
  }
}
