import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/repositories/snake_game_repository.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/logic/tetromino.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/di.dart';

const String _tetrisGameCode = 'tetris';
const int _loopMs = 50;
const int _lockDelayMs = 500;
const int _lockResetCap = 15;
const int _nextQueueSize = 5;

final tetrisGameProvider =
    StateNotifierProvider.autoDispose<TetrisGameNotifier, TetrisGameState>((
      ref,
    ) {
      return TetrisGameNotifier(ref);
    });

class TetrisGameNotifier extends StateNotifier<TetrisGameState> {
  TetrisGameNotifier(this.ref) : super(const TetrisGameState());

  final Ref ref;
  final SnakeGameRepository _repository = getIt<SnakeGameRepository>();

  Timer? _timer;
  Random _rng = Random();
  final List<PieceType> _bag = [];

  int? _sessionId;

  /// Reloj monótono para la duración (inmune a cambios de hora del dispositivo).
  final Stopwatch _runWatch = Stopwatch();
  bool _closed = false;

  // Acumuladores del bucle (ms).
  int _fallAccum = 0;
  int _lockAccum = 0;
  int _lockResets = 0;
  bool _lastWasRotation = false;
  int _baseGravity = 800; // gravedad inicial (para la rampa del modo infinito)

  // ---- Ciclo de vida -------------------------------------------------------

  Future<void> startGame({int level = 1}) async {
    _timer?.cancel();
    state = state.copyWith(
      isStarting: true,
      startFailed: false,
      startError: () => null,
      result: () => null,
    );

    try {
      final session = await _repository.startGame(_tetrisGameCode, level);

      _sessionId = session.sessionId;
      _baseGravity = session.tickMs;
      _rng = Random(session.seed);
      _bag.clear();
      _runWatch
        ..reset()
        ..start();
      _closed = false;
      _fallAccum = 0;
      _lockAccum = 0;
      _lockResets = 0;
      _lastWasRotation = false;

      final w = session.gridWidth;
      final h = session.gridHeight;

      // Tablero vacío + basura inicial (las "walls" del nivel son bloques
      // pre-ocupados al fondo).
      final board = List.generate(
        h,
        (_) => List<Color?>.filled(w, null),
        growable: false,
      );
      for (final cell in session.walls) {
        final x = cell.dx.toInt();
        final y = cell.dy.toInt();
        if (y >= 0 && y < h && x >= 0 && x < w) {
          board[y][x] = AppColorsGarbage.color;
        }
      }

      final queue = <PieceType>[
        for (var i = 0; i < _nextQueueSize; i++) _draw(),
      ];

      state = TetrisGameState(
        gridWidth: w,
        gridHeight: h,
        board: board,
        nextQueue: queue,
        score: 0,
        lines: 0,
        level: session.level,
        targetScore: session.targetScore,
        gravityMs: session.tickMs,
        sessionId: session.sessionId,
        isStarting: false,
      );

      _spawnFromQueue();
      _timer = Timer.periodic(const Duration(milliseconds: _loopMs), (_) {
        _tick();
      });
    } on ServiceException catch (e) {
      state = state.copyWith(
        isStarting: false,
        startFailed: true,
        startError: () => e.message,
      );
    }
  }

  /// Saca la siguiente pieza de la cola y la hace activa.
  void _spawnFromQueue() {
    final type = state.nextQueue.first;
    final queue = [...state.nextQueue.skip(1), _draw()];
    _spawn(type, queue: queue, canHold: true);
  }

  void _spawn(PieceType type, {List<PieceType>? queue, required bool canHold}) {
    final spawnX = (state.gridWidth ~/ 2) - 2;
    const spawnY = 0;
    _lastWasRotation = false;
    _lockAccum = 0;
    _lockResets = 0;
    _fallAccum = 0;

    // Lock-out: si la pieza no entra, fin de la partida.
    if (_collides(type, 0, spawnX, spawnY, state.board)) {
      state = state.copyWith(
        currentType: () => type,
        currentRotation: 0,
        currentX: spawnX,
        currentY: spawnY,
        nextQueue: queue,
        canHold: canHold,
        ghostY: spawnY,
      );
      _lose();
      return;
    }

    state = state.copyWith(
      currentType: () => type,
      currentRotation: 0,
      currentX: spawnX,
      currentY: spawnY,
      nextQueue: queue,
      canHold: canHold,
      ghostY: _computeGhostY(type, 0, spawnX, spawnY),
    );
  }

  /// Toma una pieza de la bolsa de 7 (sembrada por el servidor).
  PieceType _draw() {
    if (_bag.isEmpty) {
      _bag.addAll(PieceType.values);
      _bag.shuffle(_rng);
    }
    return _bag.removeLast();
  }

  // ---- Bucle ---------------------------------------------------------------

  void _tick() {
    if (state.hasLost || state.isPaused || state.currentType == null) return;

    final resting = _collides(
      state.currentType!,
      state.currentRotation,
      state.currentX,
      state.currentY + 1,
      state.board,
    );

    if (!resting) {
      _lockAccum = 0;
      _fallAccum += _loopMs;
      if (_fallAccum >= state.gravityMs) {
        _fallAccum = 0;
        _move(0, 1);
      }
    } else {
      _fallAccum = 0;
      _lockAccum += _loopMs;
      if (_lockAccum >= _lockDelayMs) {
        _lock();
      }
    }
  }

  // ---- Controles -----------------------------------------------------------

  void moveLeft() => _tryShift(-1);
  void moveRight() => _tryShift(1);

  void _tryShift(int dx) {
    if (!_active) return;
    if (_move(dx, 0)) _resetLockOnAction();
  }

  /// Soft drop: baja una fila y suma 1 punto.
  void softDrop() {
    if (!_active) return;
    if (_move(0, 1)) {
      _fallAccum = 0;
      state = state.copyWith(score: state.score + 1);
    }
  }

  /// Hard drop: cae hasta el fondo (2 puntos por celda) y bloquea.
  void hardDrop() {
    if (!_active) return;
    final type = state.currentType!;
    var y = state.currentY;
    var dropped = 0;
    while (!_collides(
      type,
      state.currentRotation,
      state.currentX,
      y + 1,
      state.board,
    )) {
      y++;
      dropped++;
    }
    _lastWasRotation = false;
    state = state.copyWith(currentY: y, score: state.score + dropped * 2);
    _lock();
  }

  void rotate({bool clockwise = true}) {
    if (!_active) return;
    final type = state.currentType!;
    final from = state.currentRotation;
    final to = clockwise ? (from + 1) % 4 : (from + 3) % 4;

    for (final kick in Tetromino.kicks(type, from, to)) {
      final nx = state.currentX + kick[0];
      final ny = state.currentY + kick[1];
      if (!_collides(type, to, nx, ny, state.board)) {
        state = state.copyWith(
          currentRotation: to,
          currentX: nx,
          currentY: ny,
          ghostY: _computeGhostY(type, to, nx, ny),
        );
        _lastWasRotation = true;
        _resetLockOnAction();
        return;
      }
    }
  }

  void hold() {
    if (!_active || !state.canHold) return;
    final current = state.currentType!;
    final held = state.holdType;
    if (held == null) {
      state = state.copyWith(holdType: () => current);
      _spawnFromQueue();
    } else {
      state = state.copyWith(holdType: () => current);
      _spawn(held, canHold: false);
    }
    state = state.copyWith(canHold: false);
  }

  void togglePause() {
    if (state.hasLost) return;
    final pausing = !state.isPaused;
    // La duración no cuenta el tiempo en pausa.
    if (pausing) {
      _runWatch.stop();
    } else {
      _runWatch.start();
    }
    state = state.copyWith(isPaused: pausing);
  }

  void resetGame() {
    _timer?.cancel();
    startGame(level: state.level);
  }

  // ---- Mecánica interna ----------------------------------------------------

  bool get _active =>
      !state.hasLost && !state.isPaused && state.currentType != null;

  bool _move(int dx, int dy) {
    final type = state.currentType!;
    final nx = state.currentX + dx;
    final ny = state.currentY + dy;
    if (_collides(type, state.currentRotation, nx, ny, state.board)) {
      return false;
    }
    if (dx != 0 || dy != 0) _lastWasRotation = false;
    state = state.copyWith(
      currentX: nx,
      currentY: ny,
      ghostY: _computeGhostY(type, state.currentRotation, nx, ny),
    );
    return true;
  }

  void _resetLockOnAction() {
    if (_lockResets < _lockResetCap) {
      _lockAccum = 0;
      _lockResets++;
    }
  }

  bool _collides(
    PieceType type,
    int rot,
    int px,
    int py,
    List<List<Color?>> board,
  ) {
    for (final c in Tetromino.shapes[type]![rot]) {
      final ax = px + c[0];
      final ay = py + c[1];
      if (ax < 0 || ax >= state.gridWidth || ay >= state.gridHeight) {
        return true;
      }
      if (ay >= 0 && board[ay][ax] != null) return true;
    }
    return false;
  }

  int _computeGhostY(PieceType type, int rot, int px, int py) {
    var gy = py;
    while (!_collides(type, rot, px, gy + 1, state.board)) {
      gy++;
    }
    return gy;
  }

  /// Fija la pieza al tablero, evalúa T-spin y líneas, puntúa y spawnea.
  void _lock() {
    final type = state.currentType!;
    final rot = state.currentRotation;
    final px = state.currentX;
    final py = state.currentY;

    final board = [
      for (final row in state.board) [...row],
    ];
    final color = Tetromino.colors[type]!;
    for (final c in Tetromino.shapes[type]![rot]) {
      final ax = px + c[0];
      final ay = py + c[1];
      if (ay >= 0 && ay < state.gridHeight && ax >= 0 && ax < state.gridWidth) {
        board[ay][ax] = color;
      }
    }

    // Detección de T-spin (regla de las 3 esquinas) antes de limpiar.
    final tSpin = type == PieceType.t && _lastWasRotation
        ? _detectTSpin(rot, px, py, board)
        : _TSpin.none;

    final cleared = _clearFullRows(board);
    final points = _scoreFor(cleared, tSpin);

    state = state.copyWith(
      board: board,
      score: state.score + points,
      lines: state.lines + cleared,
      combo: cleared > 0 ? state.combo + 1 : -1,
      backToBack: _nextBackToBack(cleared, tSpin),
    );

    // Modo infinito (level 0): la gravedad acelera con las líneas (de la base
    // a 120ms), sin fin.
    if (_isInfinite && cleared > 0) {
      state = state.copyWith(
        gravityMs: (_baseGravity - state.lines * 12).clamp(120, _baseGravity),
      );
    }

    _spawnFromQueue();
  }

  bool get _isInfinite => state.level == 0;

  /// Quita las filas completas (mutando la copia) y desplaza hacia abajo.
  int _clearFullRows(List<List<Color?>> board) {
    var cleared = 0;
    for (var y = state.gridHeight - 1; y >= 0; y--) {
      if (board[y].every((c) => c != null)) {
        board.removeAt(y);
        board.insert(0, List<Color?>.filled(state.gridWidth, null));
        cleared++;
        y++; // re-evaluar la fila que bajó
      }
    }
    return cleared;
  }

  _TSpin _detectTSpin(int rot, int px, int py, List<List<Color?>> board) {
    bool filled(int cx, int cy) {
      final ax = px + cx;
      final ay = py + cy;
      if (ax < 0 || ax >= state.gridWidth || ay >= state.gridHeight) {
        return true;
      }
      if (ay < 0) return false;
      return board[ay][ax] != null;
    }

    // Esquinas de la caja 3x3 de la T.
    final a = filled(0, 0); // sup-izq
    final b = filled(2, 0); // sup-der
    final c = filled(0, 2); // inf-izq
    final d = filled(2, 2); // inf-der
    final count = [a, b, c, d].where((e) => e).length;
    if (count < 3) return _TSpin.none;

    // Esquinas "frontales" según la orientación de la T.
    final front = switch (rot) {
      0 => a && b,
      1 => b && d,
      2 => c && d,
      _ => a && c,
    };
    return front ? _TSpin.full : _TSpin.mini;
  }

  int _scoreFor(int cleared, _TSpin tSpin) {
    var base = 0;
    if (tSpin == _TSpin.full) {
      base = switch (cleared) {
        0 => 400,
        1 => 800,
        2 => 1200,
        _ => 1600,
      };
    } else if (tSpin == _TSpin.mini) {
      base = switch (cleared) {
        0 => 100,
        1 => 200,
        _ => 400,
      };
    } else {
      base = switch (cleared) {
        0 => 0,
        1 => 100,
        2 => 300,
        3 => 500,
        _ => 800,
      };
    }

    if (cleared > 0 && _isDifficult(cleared, tSpin) && state.backToBack) {
      base = (base * 1.5).floor();
    }
    // Combo (se aplica el contador ya incrementado en _lock).
    if (cleared > 0) {
      base += 50 * (state.combo + 1);
    }
    return base;
  }

  bool _isDifficult(int cleared, _TSpin tSpin) =>
      cleared == 4 || (tSpin != _TSpin.none && cleared > 0);

  bool _nextBackToBack(int cleared, _TSpin tSpin) {
    if (cleared == 0) return state.backToBack; // sin línea no cambia
    return _isDifficult(cleared, tSpin);
  }

  void _lose() {
    _timer?.cancel();
    state = state.copyWith(hasLost: true);
    _finish();
  }

  // ---- Servidor ------------------------------------------------------------

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
        foodEaten: state.lines, // métrica secundaria = líneas
        durationMs: durationMs,
      );
      if (!mounted) return;
      state = state.copyWith(isSubmitting: false, result: () => result);
    } on ServiceException catch (_) {
      if (!mounted) return;
      state = state.copyWith(isSubmitting: false);
    }
  }

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

  Future<void> abandon() async {
    final sessionId = _sessionId;
    if (_closed || sessionId == null) return;
    _closed = true;
    _timer?.cancel();
    try {
      await _repository.abandonGame(sessionId);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

enum _TSpin { none, mini, full }

/// Color de los bloques de basura (gris azulado neutro).
class AppColorsGarbage {
  static const Color color = Color(0xFF6B7A85);
}

class TetrisGameState extends Equatable {
  final int gridWidth;
  final int gridHeight;
  final List<List<Color?>> board;
  final List<PieceType> nextQueue;
  final PieceType? holdType;
  final bool canHold;

  final PieceType? currentType;
  final int currentRotation;
  final int currentX;
  final int currentY;
  final int ghostY;

  final int score;
  final int lines;
  final int level;
  final int targetScore;
  final int gravityMs;
  final int combo;
  final bool backToBack;

  final bool hasLost;
  final bool isPaused;

  final int? sessionId;
  final bool isStarting;
  final bool startFailed;
  final String? startError;
  final bool isSubmitting;
  final GameResultEntity? result;

  const TetrisGameState({
    this.gridWidth = 10,
    this.gridHeight = 20,
    this.board = const [],
    this.nextQueue = const [],
    this.holdType,
    this.canHold = true,
    this.currentType,
    this.currentRotation = 0,
    this.currentX = 0,
    this.currentY = 0,
    this.ghostY = 0,
    this.score = 0,
    this.lines = 0,
    this.level = 1,
    this.targetScore = 0,
    this.gravityMs = 800,
    this.combo = -1,
    this.backToBack = false,
    this.hasLost = false,
    this.isPaused = false,
    this.sessionId,
    this.isStarting = false,
    this.startFailed = false,
    this.startError,
    this.isSubmitting = false,
    this.result,
  });

  TetrisGameState copyWith({
    int? gridWidth,
    int? gridHeight,
    List<List<Color?>>? board,
    List<PieceType>? nextQueue,
    ValueGetter<PieceType?>? holdType,
    bool? canHold,
    ValueGetter<PieceType?>? currentType,
    int? currentRotation,
    int? currentX,
    int? currentY,
    int? ghostY,
    int? score,
    int? lines,
    int? level,
    int? targetScore,
    int? gravityMs,
    int? combo,
    bool? backToBack,
    bool? hasLost,
    bool? isPaused,
    int? sessionId,
    bool? isStarting,
    bool? startFailed,
    ValueGetter<String?>? startError,
    bool? isSubmitting,
    ValueGetter<GameResultEntity?>? result,
  }) {
    return TetrisGameState(
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      board: board ?? this.board,
      nextQueue: nextQueue ?? this.nextQueue,
      holdType: holdType != null ? holdType() : this.holdType,
      canHold: canHold ?? this.canHold,
      currentType: currentType != null ? currentType() : this.currentType,
      currentRotation: currentRotation ?? this.currentRotation,
      currentX: currentX ?? this.currentX,
      currentY: currentY ?? this.currentY,
      ghostY: ghostY ?? this.ghostY,
      score: score ?? this.score,
      lines: lines ?? this.lines,
      level: level ?? this.level,
      targetScore: targetScore ?? this.targetScore,
      gravityMs: gravityMs ?? this.gravityMs,
      combo: combo ?? this.combo,
      backToBack: backToBack ?? this.backToBack,
      hasLost: hasLost ?? this.hasLost,
      isPaused: isPaused ?? this.isPaused,
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
    gridWidth,
    gridHeight,
    board,
    nextQueue,
    holdType,
    canHold,
    currentType,
    currentRotation,
    currentX,
    currentY,
    ghostY,
    score,
    lines,
    level,
    targetScore,
    gravityMs,
    combo,
    backToBack,
    hasLost,
    isPaused,
    sessionId,
    isStarting,
    startFailed,
    startError,
    isSubmitting,
    result,
  ];
}
