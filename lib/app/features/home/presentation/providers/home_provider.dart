import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/home/domain/entities/game_entity.dart';
import 'package:pixel_retro_app/app/features/home/domain/repositories/home_repository.dart';
import 'package:pixel_retro_app/di.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});

/// Carga la lista de juegos al entrar a la pantalla.
final homeInitProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.read(homeProvider.notifier).loadGames();
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this.ref) : super(const HomeState());

  final Ref ref;
  final HomeRepository repository = getIt<HomeRepository>();

  /// Lanza [ServiceException] si falla; la UI lo maneja vía AsyncValue.
  Future<void> loadGames() async {
    final games = await repository.getGames();
    state = state.copyWith(
      games: games,
      gameSelected: games.isNotEmpty ? games.first : null,
    );
  }

  void selectGame(String game) {
    if (state.games.isEmpty) return;
    final selectedGame = state.games.firstWhere(
      (g) => g.title == game,
      orElse: () => state.gameSelected ?? state.games.first,
    );
    state = state.copyWith(gameSelected: selectedGame);
  }
}

class HomeState extends Equatable {
  final GameEntity? gameSelected;
  final List<GameEntity> games;

  const HomeState({this.gameSelected, this.games = const []});

  HomeState copyWith({GameEntity? gameSelected, List<GameEntity>? games}) {
    return HomeState(
      gameSelected: gameSelected ?? this.gameSelected,
      games: games ?? this.games,
    );
  }

  @override
  List<Object?> get props => [gameSelected, games];
}
