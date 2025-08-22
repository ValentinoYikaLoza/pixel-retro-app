import 'package:flutter_riverpod/flutter_riverpod.dart';

final snakeGameProvider =
    StateNotifierProvider<SnakeGameNotifier, SnakeGameState>((ref) {
      return SnakeGameNotifier(ref);
    });

class SnakeGameNotifier extends StateNotifier<SnakeGameState> {
  SnakeGameNotifier(this.ref) : super(SnakeGameState());

  final Ref ref;

  // Add your game logic here
}

class SnakeGameState {
  SnakeGameState();

  // Add your state properties and methods here
}
