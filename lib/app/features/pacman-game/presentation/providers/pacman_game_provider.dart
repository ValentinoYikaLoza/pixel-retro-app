import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/logic/pacman_maze.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/repositories/snake_game_repository.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/di.dart';

/// Código del juego en el catálogo del backend (game.name).
const String _pacmanGameCode = 'pacman';

/// Cadencia del bucle (~60 fps). El movimiento usa este dt fijo.
const int _loopMs = 16;

/// Vidas dentro de la partida (independiente de la "vida" que cuesta abrir
/// sesión). Pierdes una al ser atrapado; game over al llegar a 0.
const int _startLives = 3;

final pacmanGameProvider =
    StateNotifierProvider.autoDispose<PacmanGameNotifier, PacmanGameState>((
      ref,
    ) {
      return PacmanGameNotifier(ref);
    });

class PacmanGameNotifier extends StateNotifier<PacmanGameState> {
  PacmanGameNotifier(this.ref) : super(const PacmanGameState());

  final Ref ref;
  final SnakeGameRepository _repository = getIt<SnakeGameRepository>();

  Timer? _timer;
  final Stopwatch _runWatch = Stopwatch();
  int? _sessionId;
  bool _closed = false;

  late PacmanMaze _maze;

  // --- Pac-Man: tile actual + progreso (0..1) hacia el siguiente en _dir ---
  int _tx = 0, _ty = 0;
  double _prog = 0;
  PacDir _dir = PacDir.none;
  PacDir _want = PacDir.none;

  double _speed = 0; // casillas por ms (= 1 / tick_ms)
  int _score = 0;
  int _pellets = 0; // comidos (métrica del objetivo)
  int _lives = _startLives;
  int _frame = 0;
  double _mouth = 0; // fase de la boca (animación)

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
      final session = await _repository.startGame(_pacmanGameCode, level);

      _sessionId = session.sessionId;
      _maze = PacmanMaze(kPacmanMazeL1);
      _maze.resetPellets();
      _speed = 1 / session.tickMs;
      _runWatch
        ..reset()
        ..start();
      _closed = false;

      _resetActors();
      _score = 0;
      _pellets = 0;
      _lives = _startLives;
      _frame = 0;
      // Come el pellet de la casilla de spawn (si lo hay): solo se come al
      // "llegar" a una casilla, así que el inicial nunca se comería y el nivel
      // no podría completarse.
      _eatAt(_tx, _ty);

      state = PacmanGameState(
        isStarting: false,
        maze: _maze,
        gridWidth: _maze.width,
        gridHeight: _maze.height,
        level: session.level,
        targetScore: session.targetScore,
        sessionId: session.sessionId,
        pacX: _tx.toDouble(),
        pacY: _ty.toDouble(),
        pacDir: _dir,
        score: _score,
        pelletsEaten: _pellets,
        lives: _lives,
        frame: 0,
      );

      _timer = Timer.periodic(
        const Duration(milliseconds: _loopMs),
        (_) => _loop(),
      );
    } on ServiceException catch (e) {
      state = state.copyWith(
        isStarting: false,
        startFailed: true,
        startError: () => e.message,
      );
    }
  }

  /// Coloca a Pac-Man en su spawn mirando a la izquierda.
  void _resetActors() {
    _tx = _maze.pacSpawn.x;
    _ty = _maze.pacSpawn.y;
    _prog = 0;
    _dir = PacDir.left;
    _want = PacDir.left;
  }

  // ---- Bucle ---------------------------------------------------------------

  void _loop() {
    if (state.hasWon || state.hasLost || state.isPaused) return;

    _stepPac(_loopMs.toDouble());
    _mouth = (_mouth + 0.18) % 1.0;
    _frame++;

    // Comer todos los pellets = nivel superado.
    if (_maze.cleared) {
      _win();
      return;
    }

    state = state.copyWith(
      pacX: _pacPxX(),
      pacY: _pacPxY(),
      pacDir: _dir,
      score: _score,
      pelletsEaten: _pellets,
      lives: _lives,
      mouth: _mouth,
      frame: _frame,
    );
  }

  /// Avanza a Pac-Man [dtMs] ms, resolviendo giros y paredes en los centros de
  /// casilla. El movimiento "salta" de centro en centro: en cada centro decide
  /// si gira hacia [_want] o se detiene ante una pared.
  void _stepPac(double dtMs) {
    // Reversa (180°): permitida en cualquier punto → invierte sentido.
    if (_want != PacDir.none && _want == _dir.opposite && _dir != PacDir.none) {
      _tx = _maze.wrapX(_tx + _dir.vec.x, _ty);
      _ty += _dir.vec.y;
      _dir = _want;
      _prog = 1 - _prog;
      _want = PacDir.none;
    }

    if (_dir == PacDir.none) {
      // Parado: intenta arrancar hacia _want.
      if (_want != PacDir.none && _open(_tx, _ty, _want)) {
        _dir = _want;
      } else {
        return;
      }
    }

    var dist = _speed * dtMs; // casillas a avanzar
    while (dist > 0) {
      final toCenter = 1 - _prog;
      if (dist < toCenter) {
        _prog += dist;
        dist = 0;
      } else {
        // Llega al centro de la siguiente casilla.
        dist -= toCenter;
        _tx = _maze.wrapX(_tx + _dir.vec.x, _ty);
        _ty += _dir.vec.y;
        _prog = 0;
        _eatAt(_tx, _ty);

        // En el centro: gira si se pidió y se puede; si no, sigue o se detiene.
        if (_want != PacDir.none && _open(_tx, _ty, _want)) {
          _dir = _want;
        }
        if (!_open(_tx, _ty, _dir)) {
          _dir = PacDir.none;
          break;
        }
      }
    }
  }

  /// ¿La casilla vecina en [d] desde (x,y) es transitable para Pac-Man?
  bool _open(int x, int y, PacDir d) {
    final nx = _maze.wrapX(x + d.vec.x, y);
    final ny = y + d.vec.y;
    if (ny < 0 || ny >= _maze.height) return false;
    return !_maze.isWall(nx, ny);
  }

  void _eatAt(int x, int y) {
    final what = _maze.eat(x, y);
    if (what == 'pellet') {
      _score += 10;
      _pellets++;
    } else if (what == 'power') {
      _score += 50;
      _pellets++;
      // Fase 2: aquí se activará el modo "frightened" de los fantasmas.
    }
  }

  double _pacPxX() => _tx + _dir.vec.x * _prog;
  double _pacPxY() => _ty + _dir.vec.y * _prog;

  // ---- Entrada -------------------------------------------------------------

  /// Dirección deseada (desde el swipe). Se aplica en el próximo centro válido.
  void setWantDir(PacDir d) {
    if (d == PacDir.none) return;
    _want = d;
  }

  void togglePause() {
    if (state.hasWon || state.hasLost) return;
    if (state.isPaused) {
      _runWatch.start();
      _timer = Timer.periodic(
        const Duration(milliseconds: _loopMs),
        (_) => _loop(),
      );
    } else {
      _timer?.cancel();
      _runWatch.stop();
    }
    state = state.copyWith(isPaused: !state.isPaused);
  }

  // ---- Fin de partida ------------------------------------------------------

  void _win() {
    _timer?.cancel();
    state = state.copyWith(hasWon: true, frame: _frame, pelletsEaten: _pellets);
    _finish();
  }

  // Lo usará la Fase 2 (colisión con fantasmas sin power): perder una vida y,
  // si llega a 0, terminar la partida.
  // ignore: unused_element
  void _lose() {
    _timer?.cancel();
    state = state.copyWith(hasLost: true, frame: _frame);
    _finish();
  }

  Future<void> _finish() async {
    final sessionId = _sessionId;
    if (_closed || sessionId == null) return;
    _closed = true;

    state = state.copyWith(isSubmitting: true);
    try {
      final result = await _repository.finishGame(
        sessionId: sessionId,
        score: _score,
        foodEaten: _pellets,
        durationMs: _runWatch.elapsedMilliseconds,
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
    } catch (_) {
      // Silencioso: salir no debe bloquear la navegación.
    }
  }

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

class PacmanGameState extends Equatable {
  /// Laberinto (mutado en sitio al comer; el repintado lo dispara [frame]).
  final PacmanMaze? maze;

  final double pacX;
  final double pacY;
  final PacDir pacDir;
  final double mouth;

  final int score;
  final int pelletsEaten;
  final int lives;

  final int gridWidth;
  final int gridHeight;
  final int level;
  final int targetScore;

  final bool hasWon;
  final bool hasLost;
  final bool isPaused;

  final int? sessionId;
  final bool isStarting;
  final bool startFailed;
  final String? startError;
  final bool isSubmitting;
  final GameResultEntity? result;

  /// Contador de frame: cambia cada tick para forzar el repintado del board
  /// aunque el laberinto se mute en sitio.
  final int frame;

  const PacmanGameState({
    this.maze,
    this.pacX = 0,
    this.pacY = 0,
    this.pacDir = PacDir.none,
    this.mouth = 0,
    this.score = 0,
    this.pelletsEaten = 0,
    this.lives = _startLives,
    this.gridWidth = 28,
    this.gridHeight = 29,
    this.level = 1,
    this.targetScore = 0,
    this.hasWon = false,
    this.hasLost = false,
    this.isPaused = false,
    this.sessionId,
    this.isStarting = false,
    this.startFailed = false,
    this.startError,
    this.isSubmitting = false,
    this.result,
    this.frame = 0,
  });

  PacmanGameState copyWith({
    PacmanMaze? maze,
    double? pacX,
    double? pacY,
    PacDir? pacDir,
    double? mouth,
    int? score,
    int? pelletsEaten,
    int? lives,
    int? gridWidth,
    int? gridHeight,
    int? level,
    int? targetScore,
    bool? hasWon,
    bool? hasLost,
    bool? isPaused,
    int? sessionId,
    bool? isStarting,
    bool? startFailed,
    ValueGetter<String?>? startError,
    bool? isSubmitting,
    ValueGetter<GameResultEntity?>? result,
    int? frame,
  }) {
    return PacmanGameState(
      maze: maze ?? this.maze,
      pacX: pacX ?? this.pacX,
      pacY: pacY ?? this.pacY,
      pacDir: pacDir ?? this.pacDir,
      mouth: mouth ?? this.mouth,
      score: score ?? this.score,
      pelletsEaten: pelletsEaten ?? this.pelletsEaten,
      lives: lives ?? this.lives,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      level: level ?? this.level,
      targetScore: targetScore ?? this.targetScore,
      hasWon: hasWon ?? this.hasWon,
      hasLost: hasLost ?? this.hasLost,
      isPaused: isPaused ?? this.isPaused,
      sessionId: sessionId ?? this.sessionId,
      isStarting: isStarting ?? this.isStarting,
      startFailed: startFailed ?? this.startFailed,
      startError: startError != null ? startError() : this.startError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result != null ? result() : this.result,
      frame: frame ?? this.frame,
    );
  }

  @override
  List<Object?> get props => [
    pacX,
    pacY,
    pacDir,
    mouth,
    score,
    pelletsEaten,
    lives,
    gridWidth,
    gridHeight,
    level,
    targetScore,
    hasWon,
    hasLost,
    isPaused,
    sessionId,
    isStarting,
    startFailed,
    startError,
    isSubmitting,
    result,
    frame,
  ];
}
