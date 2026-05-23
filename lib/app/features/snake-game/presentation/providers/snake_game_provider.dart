import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final snakeGameProvider =
    StateNotifierProvider.autoDispose<SnakeGameNotifier, SnakeGameState>((ref) {
      return SnakeGameNotifier(ref);
    });

class SnakeGameNotifier extends StateNotifier<SnakeGameState> {
  SnakeGameNotifier(this.ref) : super(SnakeGameState());

  final Ref ref;
  Timer? _timer;
  Direction? _nextDirection;

  void initGame() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => _move());

    state = state.copyWith(
      snake: [Offset(10, 10)],
      food: () => Offset(15, 15),
      extraFood: null,
      direction: Direction.right,
      score: 0,
      hasLost: false,
      isPaused: false,
      gridWidth: 30, // Ancho del grid
      gridHeight: 20, // Alto del grid
    );
  }

  void _move() {
    if (state.hasLost) return;

    // create a new snake list
    final newSnake = List<Offset>.from(state.snake);
    final head = newSnake.first;

    // Determine direction (prioritize next direction if available)
    final direction = _nextDirection ?? state.direction;

    // Calculate new head position with wrap-around
    Offset newHead;
    switch (direction) {
      case Direction.up:
        newHead = Offset(head.dx, (head.dy - 1) % state.gridHeight);
        break;
      case Direction.down:
        newHead = Offset(head.dx, (head.dy + 1) % state.gridHeight);
        break;
      case Direction.left:
        newHead = Offset((head.dx - 1) % state.gridWidth, head.dy);
        break;
      case Direction.right:
        newHead = Offset((head.dx + 1) % state.gridWidth, head.dy);
        break;
    }

    // Aseguramos que las coordenadas sean positivas
    newHead = Offset(
      newHead.dx < 0 ? newHead.dx + state.gridWidth : newHead.dx,
      newHead.dy < 0 ? newHead.dy + state.gridHeight : newHead.dy,
    );

    // Check for collisions (solo con el cuerpo ahora)
    if (_checkCollision(newHead, newSnake)) {
      state = state.copyWith(hasLost: true);
      _timer?.cancel();
      return;
    }

    // Move snake
    newSnake.insert(0, newHead);
    _nextDirection = null;

    // Check if food was eaten
    if (newHead == state.food) {
      // Generate new food
      final newFood = _generateFood(newSnake);

      // Determinar el nuevo extraFood
      Offset? newExtraFood;
      if ((state.score + 1) % 5 == 0 && state.score + 1 != 0) {
        newExtraFood = _generateExtraFood(newSnake);
      } else {
        newExtraFood = null; // Siempre eliminar extraFood existente
      }

      // ✅ Una sola actualización del estado
      state = state.copyWith(
        snake: newSnake,
        food: () => newFood,
        extraFood: () => newExtraFood,
        direction: direction,
        score: state.score + 1,
      );
    } else if (newHead == state.extraFood) {
      // Generate new food (since we ate extra food, regular food stays)
      final newFood = _generateFood(newSnake);

      state = state.copyWith(
        snake: newSnake,
        food: () => newFood,
        extraFood: () => null,
        direction: direction,
        score: state.score + 5,
      );
    } else {
      // Remove tail if no food was eaten
      newSnake.removeLast();

      state = state.copyWith(snake: newSnake, direction: direction);
    }
  }

  bool _checkCollision(Offset head, List<Offset> snake) {
    // Solo verificamos colisión con el propio cuerpo (skip the head)
    for (int i = 1; i < snake.length; i++) {
      if (head == snake[i]) {
        return true;
      }
    }

    return false;
  }

  Offset _generateFood(List<Offset> snake) {
    final random = Random();
    Offset newFood;

    do {
      newFood = Offset(
        random.nextInt(state.gridWidth).toDouble(),
        random.nextInt(state.gridHeight).toDouble(),
      );
    } while (snake.contains(newFood));

    return newFood;
  }

  Offset _generateExtraFood(List<Offset> snake) {
    final random = Random();
    Offset newExtraFood;

    do {
      newExtraFood = Offset(
        random.nextInt(state.gridWidth).toDouble(),
        random.nextInt(state.gridHeight).toDouble(),
      );
    } while (snake.contains(newExtraFood));

    return newExtraFood;
  }

  void changeDirection(Direction newDirection) {
    // Prevent 180-degree turns
    if ((state.direction == Direction.up && newDirection == Direction.down) ||
        (state.direction == Direction.down && newDirection == Direction.up) ||
        (state.direction == Direction.left &&
            newDirection == Direction.right) ||
        (state.direction == Direction.right &&
            newDirection == Direction.left)) {
      return;
    }

    _nextDirection = newDirection;
  }

  void togglePause() {
    if (state.hasLost) return;

    if (state.isPaused) {
      // Resume game
      _timer = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) => _move(),
      );
    } else {
      // Pause game
      _timer?.cancel();
    }

    state = state.copyWith(isPaused: !state.isPaused);
  }

  void resetGame() {
    _timer?.cancel();
    initGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class SnakeGameState extends Equatable {
  final List<Offset> snake;
  final Offset food;
  final Offset? extraFood;
  final Direction direction;
  final int score;
  final bool hasLost;
  final bool isPaused;
  final int gridWidth; // Cambiado de gridSize
  final int gridHeight; // Nueva propiedad

  const SnakeGameState({
    this.snake = const [],
    this.food = const Offset(0, 0),
    this.extraFood,
    this.direction = Direction.right,
    this.score = 0,
    this.hasLost = false,
    this.isPaused = false,
    this.gridWidth = 30, // Ancho por defecto
    this.gridHeight = 20, // Alto por defecto
  });
  // Add your state properties and methods here

  SnakeGameState copyWith({
    List<Offset>? snake,
    ValueGetter<Offset>? food,
    ValueGetter<Offset?>? extraFood,
    Direction? direction,
    int? score,
    bool? hasLost,
    bool? isPaused,
    int? gridWidth,
    int? gridHeight,
  }) {
    return SnakeGameState(
      snake: snake ?? this.snake,
      food: food != null ? food() : this.food,
      extraFood: extraFood != null ? extraFood() : this.extraFood,
      direction: direction ?? this.direction,
      score: score ?? this.score,
      hasLost: hasLost ?? this.hasLost,
      isPaused: isPaused ?? this.isPaused,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
    );
  }

  @override
  List<Object?> get props => [
    snake,
    food,
    extraFood,
    direction,
    score,
    hasLost,
    isPaused,
    gridWidth,
    gridHeight,
  ];
}

enum Direction { up, down, left, right }
