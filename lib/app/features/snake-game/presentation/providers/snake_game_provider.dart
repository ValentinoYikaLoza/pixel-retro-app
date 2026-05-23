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

  /// Paredes del nivel (set para colisión/spawn en O(1)).
  Set<Offset> _walls = {};

  int? _sessionId;

  /// Reloj monótono para la duración (inmune a cambios de hora del dispositivo).
  final Stopwatch _runWatch = Stopwatch();

  /// Evita cerrar la partida dos veces (finish + abandon compiten al salir).
  bool _closed = false;

  /// Abre una partida del nivel indicado en el servidor (consume vida) y arranca
  /// el bucle con la semilla, paredes y config recibidas. Lo llama la pantalla
  /// al entrar y en cada reintento.
  Future<void> startGame({int level = 1}) async {
    _timer?.cancel();
    state = state.copyWith(
      isStarting: true,
      startFailed: false,
      startError: () => null,
      result: () => null,
    );

    try {
      final session = await _repository.startGame(_snakeGameCode, level);

      _sessionId = session.sessionId;
      _rng = Random(session.seed);
      _walls = session.walls.toSet();
      _runWatch
        ..reset()
        ..start();
      _closed = false;
      _nextDirection = null;

      // La serpiente aparece en el centro (la zona segura del nivel).
      final start = [
        Offset(
          (session.gridWidth ~/ 2).toDouble(),
          (session.gridHeight ~/ 2).toDouble(),
        ),
      ];

      state = SnakeGameState(
        snake: start,
        food: _generateFood(start, session.gridWidth, session.gridHeight),
        extraFood: null,
        direction: Direction.right,
        score: 0,
        foodEaten: 0,
        hasLost: false,
        isPaused: false,
        gridWidth: session.gridWidth,
        gridHeight: session.gridHeight,
        tickMs: session.tickMs,
        wrapAround: session.wrapAround,
        walls: session.walls,
        level: session.level,
        targetScore: session.targetScore,
        sessionId: session.sessionId,
        isStarting: false,
      );

      _timer = Timer.periodic(
        Duration(milliseconds: session.tickMs),
        (_) => _move(),
      );
    } on ServiceException catch (e) {
      // Sin vidas, nivel bloqueado o error: la pantalla reacciona y vuelve.
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

    var nx = head.dx.toInt();
    var ny = head.dy.toInt();
    switch (direction) {
      case Direction.up:
        ny -= 1;
        break;
      case Direction.down:
        ny += 1;
        break;
      case Direction.left:
        nx -= 1;
        break;
      case Direction.right:
        nx += 1;
        break;
    }

    if (state.wrapAround) {
      nx = (nx + state.gridWidth) % state.gridWidth;
      ny = (ny + state.gridHeight) % state.gridHeight;
    } else if (nx < 0 ||
        nx >= state.gridWidth ||
        ny < 0 ||
        ny >= state.gridHeight) {
      // Borde sólido: salir del tablero es perder.
      _lose();
      return;
    }

    final newHead = Offset(nx.toDouble(), ny.toDouble());

    // Colisión con una pared del nivel o con el propio cuerpo: fin de partida.
    if (_walls.contains(newHead) || _checkCollision(newHead, newSnake)) {
      _lose();
      return;
    }

    newSnake.insert(0, newHead);
    _nextDirection = null;

    if (newHead == state.food) {
      final newFood = _generateFood(
        newSnake,
        state.gridWidth,
        state.gridHeight,
      );

      Offset? newExtraFood;
      if ((state.score + 1) % 5 == 0 && state.score + 1 != 0) {
        newExtraFood = _generateFood(
          newSnake,
          state.gridWidth,
          state.gridHeight,
        );
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
      final newFood = _generateFood(
        newSnake,
        state.gridWidth,
        state.gridHeight,
      );

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

  void _lose() {
    _timer?.cancel();
    state = state.copyWith(hasLost: true);
    _finish();
  }

  /// Cierra la partida en el servidor y guarda las recompensas para el panel
  /// de resultados. El servidor valida el score y otorga exp/coins/misiones.
  Future<void> _finish() async {
    final sessionId = _sessionId;
    if (_closed || sessionId == null) return;
    _closed = true;

    final durationMs = _runWatch.elapsedMilliseconds;

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
            levelCleared: current.levelCleared,
            unlockedNext: current.unlockedNext,
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

  /// Celda libre aleatoria (excluye serpiente y paredes). Con barrido de
  /// respaldo para no quedar en bucle si el tablero está casi lleno.
  Offset _generateFood(List<Offset> snake, int w, int h) {
    for (int i = 0; i < 200; i++) {
      final c = Offset(_rng.nextInt(w).toDouble(), _rng.nextInt(h).toDouble());
      if (!snake.contains(c) && !_walls.contains(c)) return c;
    }
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final c = Offset(x.toDouble(), y.toDouble());
        if (!snake.contains(c) && !_walls.contains(c)) return c;
      }
    }
    return const Offset(0, 0);
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
      _runWatch.start(); // reanuda: el cronómetro vuelve a contar
      _timer = Timer.periodic(
        Duration(milliseconds: state.tickMs),
        (_) => _move(),
      );
    } else {
      _timer?.cancel();
      _runWatch.stop(); // pausa: la duración no cuenta el tiempo en pausa
    }

    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// Reintento tras perder: abre una nueva partida del mismo nivel (otra vida).
  void resetGame() {
    _timer?.cancel();
    startGame(level: state.level);
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
  final bool wrapAround;
  final List<Offset> walls;
  final int level;
  final int targetScore;

  /// Id de la sesión abierta en el servidor (null hasta `startGame`).
  final int? sessionId;

  /// `startGame` en curso (mostrar loader).
  final bool isStarting;

  /// `startGame` falló (sin vidas / nivel bloqueado): la pantalla vuelve.
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
    this.wrapAround = true,
    this.walls = const [],
    this.level = 1,
    this.targetScore = 0,
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
    bool? wrapAround,
    List<Offset>? walls,
    int? level,
    int? targetScore,
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
      wrapAround: wrapAround ?? this.wrapAround,
      walls: walls ?? this.walls,
      level: level ?? this.level,
      targetScore: targetScore ?? this.targetScore,
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
    wrapAround,
    walls,
    level,
    targetScore,
    sessionId,
    isStarting,
    startFailed,
    startError,
    isSubmitting,
    result,
  ];
}

enum Direction { up, down, left, right }
