import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/home/presentation/data/game_data.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this.ref) : super(HomeState());

  final Ref ref;

  void initGames() {
    state = state.copyWith(games: gameData, gameSelected: gameData[0]);
  }

  void selectGame(String game) {
    final selectedGame = state.games.firstWhere((g) => g.title == game);
    state = state.copyWith(gameSelected: selectedGame);
  }
}

class HomeState {
  final GameModel? gameSelected;
  final List<GameModel> games;

  HomeState({this.gameSelected, this.games = const []});

  HomeState copyWith({GameModel? gameSelected, List<GameModel>? games}) {
    return HomeState(
      gameSelected: gameSelected ?? this.gameSelected,
      games: games ?? this.games,
    );
  }
}

enum Game { snake, tetris, pixelInvader, pacman }

class GameModel {
  final Game game;
  final String title;
  final String name;

  GameModel({required this.game, required this.title, required this.name});
}
