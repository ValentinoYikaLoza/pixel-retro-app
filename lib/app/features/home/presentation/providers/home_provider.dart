import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';
import 'package:pixel_retro_app/app/features/home/domain/repositories/home_repository.dart';
import 'package:pixel_retro_app/di.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this.ref)
    : super(
        HomeState(
          games: [
            GameEntity(id: 1, name: 'snake', title: 'Snake'),
            GameEntity(id: 2, name: 'tetris', title: 'Tetris'),
            GameEntity(id: 3, name: 'invader', title: 'Pixel Invader'),
            GameEntity(id: 4, name: 'pacman', title: 'Pacman'),
          ],
          gameSelected: GameEntity(id: 1, name: 'snake', title: 'Snake'),
        ),
      );

  final Ref ref;
  final HomeRepository repository = getIt<HomeRepository>();

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
