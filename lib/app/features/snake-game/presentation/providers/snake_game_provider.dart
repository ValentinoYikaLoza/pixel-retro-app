import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/repositories/snake_game_repository.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/di.dart';

/// Código del juego en el catálogo del backend (game.name).
const String _snakeGameCode = 'snake';

final snakeGameProvider =
    StateNotifierProvider.autoDispose<SnakeGameNotifier, SnakeGameState>((ref) {
      return SnakeGameNotifier(ref);
    });

class SnakeGameNotifier extends StateNotifier<SnakeGameState> {
  SnakeGameNotifier(this.ref) : super(const SnakeGameState());

  final Ref ref;
  final SnakeGameRepository _repository = getIt<SnakeGameRepository>();

  Timer? _timer;
  Direction? _nextDirection;

  /// RNG sembrado por el servidor: hace la comida reproducible (anti-trampa).
  Random _rng = Random();
  int? _sessionId;
  DateTime? _startedAt;

  /// Evita cerrar la partida dos veces (finish + abandon compiten al salir).
  bool _closed = false;

  /// Abre una partida en el servidor (consume vida) y arranca el bucle con la
  /// semilla y la config recibidas. Lo llama la pantalla al entrar y en cada
  /// reintento.
  Future<void> startGame() async {
    _timer?.cancel();
    state = state.copyWith(
      isStarting: true,
      startFailed: false,
      startError: () => null,
      result: () => null,
    );

    try {
      final session = await _repository.startGame(_snakeGameCode);

      _sessionId = session.sessionId;
      _rng = Random(session.seed);
      _startedAt = DateTime.now();
      _closed = false;
      _nextDirection = null;

      const start = [Offset(10, 10)];
      state = SnakeGameState(
        snake: start,
        food: _generateFood(start),
        extraFood: null,
        direction: Direction.right,
        score: 0,
        foodEaten: 0,
        hasLost: false,
        isPaused: false,
        gridWidth: session.gridWidth,
        gridHeight: session.gridHeight,
        tickMs: session.tickMs,
        sessionId: session.sessionId,
        isStarting: false,
      );

      _timer = Timer.periodic(
        Duration(milliseconds: session.tickMs),
        (_) => _move(),
      );
    } on ServiceException catch (e) {
      // Sin vidas o error de red: la pantalla reacciona y vuelve a la tienda.
      state = state.copyWith(
        isStarting: false,
        startFailed: true,
        startError: () => e.message,
      );
    }
  }

  void _move() {
    if (state.hasLost) return;

    final newSnake = List<Offset>.from(state.snake);
    final head = newSnake.first;

    final direction = _nextDirection ?? state.direction;

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

    // Colisión con el propio cuerpo: fin de la partida.
    if (_checkCollision(newHead, newSnake)) {
      _timer?.cancel();
      state = state.copyWith(hasLost: true);
      _finish();
      return;
    }

    // Move snake
    newSnake.insert(0, newHead);
    _nextDirection = null;

    if (newHead == state.food) {
      final newFood = _generateFood(newSnake);

      Offset? newExtraFood;
      if ((state.score + 1) % 5 == 0 && state.score + 1 != 0) {
        newExtraFood = _generateExtraFood(newSnake);
      } else {
        newExtraFood = null;
      }

      state = state.copyWith(
        snake: newSnake,
        food: () => newFood,
        extraFood: () => newExtraFood,
        direction: direction,
        score: state.score + 1,
        foodEaten: state.foodEaten + 1,
      );
    } else if (newHead == state.extraFood) {
      final newFood = _generateFood(newSnake);

      state = state.copyWith(
        snake: newSnake,
        food: () => newFood,
        extraFood: () => null,
        direction: direction,
        score: state.score + 5,
        foodEaten: state.foodEaten + 1,
      );
    } else {
      newSnake.removeLast();
      state = state.copyWith(snake: newSnake, direction: direction);
    }
  }

  /// Cierra la partida en el servidor y guarda las recompensas para el panel
  /// de resultados. El servidor valida el score y otorga exp/coins/misiones.
  Future<void> _finish() async {
    final sessionId = _sessionId;
    if (_closed || sessionId == null) return;
    _closed = true;

    final durationMs = _startedAt == null
        ? 0
        : DateTime.now().difference(_startedAt!).inMilliseconds;

    state = state.copyWith(isSubmitting: true);
    try {
      final result = await _repository.finishGame(
        sessionId: sessionId,
        score: state.score,
        foodEaten: state.foodEaten,
        durationMs: durationMs,
      );
      if (!mounted) return;
      state = state.copyWith(isSubmitting: false, result: () => result);
    } on ServiceException catch (_) {
      if (!mounted) return;
      state = state.copyWith(isSubmitting: false);
    }
  }

  /// Duplica los puntos (exp) de la partida tras ver el anuncio recompensado.
  /// El servidor valida y otorga de forma idempotente. Devuelve la exp extra
  /// (0 si ya se cobró o falló) y refleja el total en el panel de resultados.
  Future<int> doubleReward() async {
    final sessionId = state.sessionId;
    if (sessionId == null) return 0;

    try {
      final bonus = await _repository.doubleReward(sessionId);
      final current = state.result;
      if (bonus > 0 && current != null && mounted) {
        state = state.copyWith(
          result: () => GameResultEntity(
            isHighScore: current.isHighScore,
            highScore: current.highScore,
            expGained: current.expGained + bonus,
            coinsGained: current.coinsGained,
          ),
        );
      }
      return bonus;
    } on ServiceException catch (_) {
      return 0;
    }
  }

  /// Marca la partida como abandonada si se sale sin perder. La pantalla lo
  /// llama al hacer pop. Fire-and-forget: usa singletons, no el estado.
  Future<void> abandon() async {
    final sessionId = _sessionId;
    if (_closed || sessionId == null) return;
    _closed = true;
    _timer?.cancel();
    try {
      await _repository.abandonGame(sessionId);
    } catch (_) {
      // Silencioso: salir no debe bloquear la navegación.
    }
  }

  bool _checkCollision(Offset head, List<Offset> snake) {
    for (int i = 1; i < snake.length; i++) {
      if (head == snake[i]) {
        return true;
      }
    }
    return false;
  }

  Offset _generateFood(List<Offset> snake) {
    Offset newFood;
    do {
      newFood = Offset(
        _rng.nextInt(state.gridWidth).toDouble(),
        _rng.nextInt(state.gridHeight).toDouble(),
      );
    } while (snake.contains(newFood));
    return newFood;
  }

  Offset _generateExtraFood(List<Offset> snake) {
    Offset newExtraFood;
    do {
      newExtraFood = Offset(
        _rng.nextInt(state.gridWidth).toDouble(),
        _rng.nextInt(state.gridHeight).toDouble(),
      );
    } while (snake.contains(newExtraFood));
    return newExtraFood;
  }

  void changeDirection(Direction newDirection) {
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
      _timer = Timer.periodic(
        Duration(milliseconds: state.tickMs),
        (_) => _move(),
      );
    } else {
      _timer?.cancel();
    }

    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// Reintento tras perder: abre una nueva partida (consume otra vida).
  void resetGame() {
    _timer?.cancel();
    startGame();
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
  final int foodEaten;
  final bool hasLost;
  final bool isPaused;
  final int gridWidth;
  final int gridHeight;
  final int tickMs;

  /// Id de la sesión abierta en el servidor (null hasta `startGame`).
  final int? sessionId;

  /// `startGame` en curso (mostrar loader).
  final bool isStarting;

  /// `startGame` falló (p. ej. sin vidas): la pantalla vuelve a la tienda.
  final bool startFailed;
  final String? startError;

  /// `finishGame` en curso (enviando el resultado).
  final bool isSubmitting;

  /// Recompensas devueltas al cerrar la partida (null hasta `finishGame`).
  final GameResultEntity? result;

  const SnakeGameState({
    this.snake = const [],
    this.food = const Offset(0, 0),
    this.extraFood,
    this.direction = Direction.right,
    this.score = 0,
    this.foodEaten = 0,
    this.hasLost = false,
    this.isPaused = false,
    this.gridWidth = 30,
    this.gridHeight = 20,
    this.tickMs = 200,
    this.sessionId,
    this.isStarting = false,
    this.startFailed = false,
    this.startError,
    this.isSubmitting = false,
    this.result,
  });

  SnakeGameState copyWith({
    List<Offset>? snake,
    ValueGetter<Offset>? food,
    ValueGetter<Offset?>? extraFood,
    Direction? direction,
    int? score,
    int? foodEaten,
    bool? hasLost,
    bool? isPaused,
    int? gridWidth,
    int? gridHeight,
    int? tickMs,
    int? sessionId,
    bool? isStarting,
    bool? startFailed,
    ValueGetter<String?>? startError,
    bool? isSubmitting,
    ValueGetter<GameResultEntity?>? result,
  }) {
    return SnakeGameState(
      snake: snake ?? this.snake,
      food: food != null ? food() : this.food,
      extraFood: extraFood != null ? extraFood() : this.extraFood,
      direction: direction ?? this.direction,
      score: score ?? this.score,
      foodEaten: foodEaten ?? this.foodEaten,
      hasLost: hasLost ?? this.hasLost,
      isPaused: isPaused ?? this.isPaused,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      tickMs: tickMs ?? this.tickMs,
      sessionId: sessionId ?? this.sessionId,
      isStarting: isStarting ?? this.isStarting,
      startFailed: startFailed ?? this.startFailed,
      startError: startError != null ? startError() : this.startError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result != null ? result() : this.result,
    );
  }

  @override
  List<Object?> get props => [
    snake,
    food,
    extraFood,
    direction,
    score,
    foodEaten,
    hasLost,
    isPaused,
    gridWidth,
    gridHeight,
    tickMs,
    sessionId,
    isStarting,
    startFailed,
    startError,
    isSubmitting,
    result,
  ];
}

enum Direction { up, down, left, right }
