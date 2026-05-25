import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/pacman-game/presentation/logic/pacman_actors.dart';
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

/// Duración base del modo frightened tras comer un power pellet (ms). Se acorta
/// con el nivel (ver _triggerFrightened).
const int _frightenedBaseMs = 7000;

/// Ciclo base scatter/chase (ms). Pares=scatter, impares=chase; -1 = chase
/// indefinido. En niveles altos los tramos de scatter se acortan (más
/// persecución) — ver el cálculo de _modeSchedule en startGame.
const List<int> _modeBaseScheduleMs = [7000, 20000, 7000, 20000, 5000, 20000, 5000, -1];

/// Pausa breve (ms) al iniciar y tras perder una vida.
const int _readyDurationMs = 800;

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
  final Random _rng = Random();
  int? _sessionId;
  bool _closed = false;

  late PacmanMaze _maze;

  // --- Pac-Man: tile actual + progreso (0..1) hacia el siguiente en _dir ---
  int _tx = 0, _ty = 0;
  double _prog = 0;
  PacDir _dir = PacDir.none;
  PacDir _want = PacDir.none;

  // --- Fantasmas ---
  final List<Ghost> _ghosts = [];
  Boss? _boss; // jefe (niveles 5 y 10)
  int _modeIndex = 0; // índice en _modeSchedule (par=scatter, impar=chase)
  List<int> _modeSchedule = _modeBaseScheduleMs; // ajustado por nivel
  int _modeAccumMs = 0;
  int _frightenedMs = 0; // restante de frightened
  int _ghostCombo = 0; // 0..3 → 200/400/800/1600
  int _readyMs = 0; // pausa breve (inicio / tras morir)

  double _speed = 0; // casillas por ms (= 1 / tick_ms)
  int _score = 0;
  int _pellets = 0; // comidos (métrica del objetivo)
  int _lives = _startLives;
  int _level = 1;
  int _frame = 0;
  double _mouth = 0; // fase de la boca (animación)

  // --- Fruta (bonus): aparece bajo la casa al comer ciertos pellets ---
  bool _fruitActive = false;
  int _fruitX = 0, _fruitY = 0;
  int _fruitUntilMs = 0;
  final Set<int> _fruitMilestones = {}; // pellets a los que ya apareció

  // --- Power-ups + combo (Fase 3) ---
  final List<PowerUp> _powerups = [];
  int _nextPowerAtPellets = 35; // próximo umbral de aparición
  int _speedUntil = 0, _freezeUntil = 0, _doubleUntil = 0, _magnetUntil = 0;
  int _invulnUntil = 0; // invulnerabilidad breve tras usar el escudo
  bool _shield = false;
  int _chain = 0; // pellets seguidos (cadena/combo)
  int _lastPelletMs = -100000;

  bool get _speedActive => _runWatch.elapsedMilliseconds < _speedUntil;
  bool get _freezeActive => _runWatch.elapsedMilliseconds < _freezeUntil;
  bool get _doubleActive => _runWatch.elapsedMilliseconds < _doubleUntil;
  bool get _magnetActive => _runWatch.elapsedMilliseconds < _magnetUntil;
  bool get _invuln => _runWatch.elapsedMilliseconds < _invulnUntil;
  int get _chainMult => (1 + _chain ~/ 12).clamp(1, 5);

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
      _maze = PacmanMaze(mazeForLevel(session.level));
      _maze.resetPellets();
      _speed = 1 / session.tickMs;
      _runWatch
        ..reset()
        ..start();
      _closed = false;

      _score = 0;
      _pellets = 0;
      _lives = _startLives;
      _level = session.level;
      _frame = 0;
      _modeIndex = 0;
      // Niveles altos = menos dispersión (scatter más corto) → más persecución.
      final scatterFactor = (1 - (_level - 1) * 0.09).clamp(0.25, 1.0);
      _modeSchedule = [
        for (var i = 0; i < _modeBaseScheduleMs.length; i++)
          _modeBaseScheduleMs[i] < 0
              ? -1
              : (i.isEven
                    ? (_modeBaseScheduleMs[i] * scatterFactor).round()
                    : _modeBaseScheduleMs[i]),
      ];
      _modeAccumMs = 0;
      _frightenedMs = 0;
      _ghostCombo = 0;
      _fruitActive = false;
      _fruitMilestones.clear();
      _powerups.clear();
      _nextPowerAtPellets = 35;
      _speedUntil = _freezeUntil = _doubleUntil = _magnetUntil = 0;
      _invulnUntil = 0;
      _shield = false;
      _chain = 0;
      _lastPelletMs = -100000;
      // Jefe en niveles 5 y 10 (más vida en el 10). Debe crearse antes de
      // _resetActors para que este lo recoloque.
      _boss = (session.level == 5 || session.level == 10)
          ? Boss(
              _maze.ghostExit.x,
              _maze.ghostExit.y,
              hp: session.level == 10 ? 5 : 3,
              maxHp: session.level == 10 ? 5 : 3,
            )
          : null;
      _resetActors();
      // Come el pellet de la casilla de spawn (si lo hay): solo se come al
      // "llegar" a una casilla, así que el inicial nunca se comería y el nivel
      // no podría completarse.
      _eatAt(_tx, _ty);

      state = _snapshot(
        isStarting: false,
        maze: _maze,
        gridWidth: _maze.width,
        gridHeight: _maze.height,
        level: session.level,
        targetScore: session.targetScore,
        sessionId: session.sessionId,
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

  /// Coloca a Pac-Man en su spawn (mirando a la izquierda) y (re)crea los
  /// fantasmas en la casa. Pausa breve de "listo".
  void _resetActors() {
    _tx = _maze.pacSpawn.x;
    _ty = _maze.pacSpawn.y;
    _prog = 0;
    _dir = PacDir.left;
    _want = PacDir.left;
    _spawnGhosts();
    final b = _boss;
    if (b != null) {
      b.tx = _maze.ghostExit.x;
      b.ty = _maze.ghostExit.y;
      b.prog = 0;
      b.dir = PacDir.left;
      b.hitCooldownUntil = 0;
    }
    _readyMs = _readyDurationMs;
  }

  void _spawnGhosts() {
    _ghosts.clear();
    final hc = _houseCenter;
    final exit = _maze.ghostExit;
    final base = _runWatch.elapsedMilliseconds;
    // Niveles altos = salida más rápida (más presión desde el inicio).
    final rf = (1 - (_level - 1) * 0.08).clamp(0.35, 1.0);
    int rel(int ms) => base + (ms * rf).round();
    // Blinky empieza fuera (sobre la puerta); los demás esperan dentro y salen
    // escalonados.
    _ghosts.add(
      Ghost(GhostType.blinky, exit.x, exit.y,
          mode: _globalGhostMode(), dir: PacDir.left),
    );
    _ghosts.add(
      Ghost(GhostType.pinky, hc.x, hc.y,
          mode: GhostMode.house, dir: PacDir.down, releaseAtMs: rel(2000)),
    );
    _ghosts.add(
      Ghost(GhostType.inky, _maze.house.left, hc.y,
          mode: GhostMode.house, dir: PacDir.up, releaseAtMs: rel(5000)),
    );
    _ghosts.add(
      Ghost(GhostType.clyde, _maze.house.right, hc.y,
          mode: GhostMode.house, dir: PacDir.up, releaseAtMs: rel(8000)),
    );
  }

  Point<int> get _houseCenter => Point(
    (_maze.house.left + _maze.house.right) ~/ 2,
    (_maze.house.top + _maze.house.bottom) ~/ 2,
  );

  // ---- Bucle ---------------------------------------------------------------

  void _loop() {
    if (state.hasWon || state.hasLost || state.isPaused) return;

    // Pausa de "listo" (inicio / tras morir): nada se mueve.
    if (_readyMs > 0) {
      _readyMs -= _loopMs;
      _frame++;
      state = _snapshot();
      return;
    }

    final now = _runWatch.elapsedMilliseconds;
    if (_fruitActive && now > _fruitUntilMs) _fruitActive = false;
    _powerups.removeWhere((p) => now > p.untilMs); // cápsulas que caducan

    _advanceMode(_loopMs);
    _stepPac(_loopMs.toDouble());
    if (_magnetActive) _magnetVacuum();
    // Los fantasmas (y el jefe) no se mueven mientras dure el "freeze".
    if (!_freezeActive) {
      for (final g in _ghosts) {
        _stepGhost(g, _loopMs.toDouble());
      }
      if (_boss != null) _stepBoss(_loopMs.toDouble());
    }
    _checkCollisions();

    _mouth = (_mouth + 0.18) % 1.0;
    _frame++;

    if (state.hasWon || state.hasLost) return;

    // Comer todos los pellets = nivel superado.
    if (_maze.cleared) {
      _win();
      return;
    }

    state = _snapshot();
  }

  /// Avanza el cronómetro de modo (scatter/chase). Congelado mientras dura el
  /// frightened. Al cambiar de fase, los fantasmas en el laberinto se invierten.
  void _advanceMode(int dtMs) {
    if (_frightenedMs > 0) {
      _frightenedMs -= dtMs;
      if (_frightenedMs <= 0) {
        _frightenedMs = 0;
        for (final g in _ghosts) {
          if (g.mode == GhostMode.frightened) g.mode = _globalGhostMode();
        }
      }
      return;
    }

    final limit = _modeSchedule[_modeIndex];
    if (limit < 0) return; // chase indefinido
    _modeAccumMs += dtMs;
    if (_modeAccumMs >= limit) {
      _modeAccumMs = 0;
      _modeIndex++;
      final m = _globalGhostMode();
      for (final g in _ghosts) {
        if (g.inMaze) {
          g.mode = m;
          g.dir = g.dir.opposite; // inversión clásica al cambiar de fase
        }
      }
    }
  }

  GhostMode _globalGhostMode() =>
      _modeIndex.isEven ? GhostMode.scatter : GhostMode.chase;

  // ---- Pac-Man -------------------------------------------------------------

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
      if (_want != PacDir.none && _open(_tx, _ty, _want)) {
        _dir = _want;
      } else {
        return;
      }
    }

    var dist = _speed * (_speedActive ? 1.5 : 1.0) * dtMs;
    while (dist > 0) {
      final toCenter = 1 - _prog;
      if (dist < toCenter) {
        _prog += dist;
        dist = 0;
      } else {
        dist -= toCenter;
        _tx = _maze.wrapX(_tx + _dir.vec.x, _ty);
        _ty += _dir.vec.y;
        _prog = 0;
        _eatAt(_tx, _ty);
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
    // Fruta (bonus): se come al pasar por su casilla mientras está activa.
    if (_fruitActive && x == _fruitX && y == _fruitY) {
      _score += _fruitPoints() * (_doubleActive ? 2 : 1);
      _fruitActive = false;
    }
    _collectPowerUpAt(x, y);
    final what = _maze.eat(x, y);
    if (what == 'pellet') {
      _eatPellet(10);
    } else if (what == 'power') {
      _eatPellet(50);
      _triggerFrightened();
    }
  }

  /// Suma un pellet: actualiza la cadena (combo), aplica multiplicador y x2,
  /// y dispara apariciones de fruta/power-up.
  void _eatPellet(int base) {
    final now = _runWatch.elapsedMilliseconds;
    _chain = (now - _lastPelletMs <= 1500) ? _chain + 1 : 1;
    _lastPelletMs = now;
    _score += base * _chainMult * (_doubleActive ? 2 : 1);
    _pellets++;
    _maybeSpawnFruit();
    _maybeSpawnPowerUp();
  }

  /// Imán: come los pellets/power dentro de un radio de Pac (puntos base, sin
  /// cadena) mientras el power-up esté activo.
  void _magnetVacuum() {
    const r = 3;
    final cx = _tx;
    final cy = _ty;
    for (var dy = -r; dy <= r; dy++) {
      for (var dx = -r; dx <= r; dx++) {
        if (dx.abs() + dy.abs() > r) continue;
        final x = _maze.wrapX(cx + dx, cy + dy);
        final y = cy + dy;
        if (y < 0 || y >= _maze.height) continue;
        final what = _maze.eat(x, y);
        if (what == null) continue;
        _score += (what == 'power' ? 50 : 10) * (_doubleActive ? 2 : 1);
        _pellets++;
        if (what == 'power') _triggerFrightened();
      }
    }
  }

  void _collectPowerUpAt(int x, int y) {
    final i = _powerups.indexWhere((p) => p.tx == x && p.ty == y);
    if (i < 0) return;
    _activatePower(_powerups.removeAt(i).type);
    _score += 100 * (_doubleActive ? 2 : 1);
  }

  void _activatePower(PacPower type) {
    final now = _runWatch.elapsedMilliseconds;
    switch (type) {
      case PacPower.speed:
        _speedUntil = now + 6000;
      case PacPower.freeze:
        _freezeUntil = now + 4500;
      case PacPower.doublePoints:
        _doubleUntil = now + 9000;
      case PacPower.magnet:
        _magnetUntil = now + 6000;
      case PacPower.shield:
        _shield = true;
    }
  }

  void _maybeSpawnPowerUp() {
    if (_pellets < _nextPowerAtPellets) return;
    _nextPowerAtPellets += 35;
    _spawnPowerUp();
  }

  /// Coloca un power-up aleatorio en una casilla caminable, lejos de Pac y de la
  /// casa. Dura 12 s.
  void _spawnPowerUp() {
    const types = PacPower.values;
    for (var tries = 0; tries < 80; tries++) {
      final x = _rng.nextInt(_maze.width);
      final y = _rng.nextInt(_maze.height);
      if (_maze.isWall(x, y) || _maze.isDoor(x, y)) continue;
      if (_maze.house.containsPoint(Point(x, y))) continue;
      if ((x - _tx).abs() + (y - _ty).abs() < 5) continue;
      if (_powerups.any((p) => p.tx == x && p.ty == y)) continue;
      _powerups.add(
        PowerUp(
          types[_rng.nextInt(types.length)],
          x,
          y,
          untilMs: _runWatch.elapsedMilliseconds + 12000,
        ),
      );
      return;
    }
  }

  /// La fruta aparece bajo la casa al comer 70 y 170 pellets (una vez cada uno),
  /// y dura ~9 s.
  void _maybeSpawnFruit() {
    if (_pellets != 70 && _pellets != 170) return;
    if (!_fruitMilestones.add(_pellets)) return;
    _fruitActive = true;
    _fruitX = _maze.pacSpawn.x;
    _fruitY = _maze.pacSpawn.y;
    _fruitUntilMs = _runWatch.elapsedMilliseconds + 9000;
  }

  int _fruitPoints() => (100 * _level).clamp(100, 500);

  void _triggerFrightened() {
    // Se acorta con el nivel (de ~7 s a ~2 s): el power pellet protege menos.
    _frightenedMs = (_frightenedBaseMs - (_level - 1) * 550).clamp(
      2000,
      _frightenedBaseMs,
    );
    _ghostCombo = 0;
    for (final g in _ghosts) {
      if (g.inMaze) {
        g.mode = GhostMode.frightened;
        g.dir = g.dir.opposite;
      }
    }
  }

  double _pacPxX() => _tx + _dir.vec.x * _prog;
  double _pacPxY() => _ty + _dir.vec.y * _prog;

  // ---- Fantasmas -----------------------------------------------------------

  void _stepGhost(Ghost g, double dtMs) {
    switch (g.mode) {
      case GhostMode.house:
        _stepHouse(g, dtMs);
      case GhostMode.leaving:
        _moveGhost(g, dtMs, 0.6, true, (gg) => _chooseToward(gg, _maze.ghostExit, true));
        // Sale por arriba de la puerta: al alcanzar la fila de salida, se une al
        // laberinto (evita pasarse y oscilar).
        if (g.ty <= _maze.ghostExit.y) {
          g.tx = _maze.ghostExit.x;
          g.ty = _maze.ghostExit.y;
          g.prog = 0;
          g.mode = _frightenedMs > 0 ? GhostMode.frightened : _globalGhostMode();
          g.dir = PacDir.left;
        }
      case GhostMode.eaten:
        // Los ojos vuelven a la puerta y "reentran" a la casa a regenerarse.
        _moveGhost(g, dtMs, 2.0, true, (gg) => _chooseToward(gg, _maze.ghostExit, true));
        if (g.ty <= _maze.ghostExit.y && g.tx == _maze.ghostExit.x) {
          g.tx = _houseCenter.x;
          g.ty = _houseCenter.y;
          g.prog = 0;
          g.dir = PacDir.up;
          g.mode = GhostMode.house;
          g.releaseAtMs = _runWatch.elapsedMilliseconds + 1500;
        }
      case GhostMode.frightened:
        _moveGhost(g, dtMs, 0.55, false, (gg) => _chooseRandom(gg, false));
      case GhostMode.scatter:
        _moveGhost(g, dtMs, 1.0, false,
            (gg) => _chooseToward(gg, _scatterCorner(gg.type), false));
      case GhostMode.chase:
        _moveGhost(g, dtMs, 1.0, false, (gg) => _chooseToward(gg, _targetFor(gg), false));
    }
  }

  /// En la casa: rebota arriba/abajo hasta que llega su turno de salir.
  void _stepHouse(Ghost g, double dtMs) {
    if (_runWatch.elapsedMilliseconds >= g.releaseAtMs) {
      g.mode = GhostMode.leaving;
      g.prog = 0;
      return;
    }
    final top = _maze.house.top;
    final bottom = _maze.house.bottom;
    var dist = _speed * 0.4 * dtMs;
    while (dist > 0) {
      final toCenter = 1 - g.prog;
      if (dist < toCenter) {
        g.prog += dist;
        dist = 0;
      } else {
        dist -= toCenter;
        g.ty += g.dir.vec.y;
        g.prog = 0;
        if (g.ty <= top) {
          g.dir = PacDir.down;
        } else if (g.ty >= bottom) {
          g.dir = PacDir.up;
        }
      }
    }
  }

  /// Mueve un fantasma [dtMs] ms a [speedScale]× la velocidad base, decidiendo
  /// la dirección en cada centro con [chooseAtCenter]. [doorOpen] permite cruzar
  /// la puerta de la casa.
  void _moveGhost(
    Ghost g,
    double dtMs,
    double speedScale,
    bool doorOpen,
    PacDir Function(Ghost) chooseAtCenter,
  ) {
    if (g.dir == PacDir.none) g.dir = chooseAtCenter(g);
    var dist = _speed * speedScale * dtMs;
    while (dist > 0) {
      final toCenter = 1 - g.prog;
      if (dist < toCenter) {
        g.prog += dist;
        dist = 0;
      } else {
        dist -= toCenter;
        g.tx = _maze.wrapX(g.tx + g.dir.vec.x, g.ty);
        g.ty += g.dir.vec.y;
        g.prog = 0;
        g.dir = chooseAtCenter(g);
        if (g.dir == PacDir.none) break;
      }
    }
  }

  /// Vecino caminable (sin retroceder) que minimiza la distancia al objetivo.
  /// Desempate clásico: arriba, izquierda, abajo, derecha.
  PacDir _chooseToward(Ghost g, Point<int> target, bool doorOpen) {
    var best = PacDir.none;
    var bestD = double.infinity;
    for (final d in const [PacDir.up, PacDir.left, PacDir.down, PacDir.right]) {
      if (d == g.dir.opposite) continue;
      final nx = _maze.wrapX(g.tx + d.vec.x, g.ty);
      final ny = g.ty + d.vec.y;
      if (ny < 0 || ny >= _maze.height) continue;
      if (_ghostBlocked(nx, ny, doorOpen)) continue;
      final ddx = (nx - target.x).toDouble();
      final ddy = (ny - target.y).toDouble();
      final dd = ddx * ddx + ddy * ddy;
      if (dd < bestD) {
        bestD = dd;
        best = d;
      }
    }
    return best == PacDir.none ? g.dir.opposite : best;
  }

  /// Dirección aleatoria válida (sin retroceder) — modo frightened.
  PacDir _chooseRandom(Ghost g, bool doorOpen) {
    final opts = <PacDir>[];
    for (final d in const [PacDir.up, PacDir.left, PacDir.down, PacDir.right]) {
      if (d == g.dir.opposite) continue;
      final nx = _maze.wrapX(g.tx + d.vec.x, g.ty);
      final ny = g.ty + d.vec.y;
      if (ny < 0 || ny >= _maze.height) continue;
      if (_ghostBlocked(nx, ny, doorOpen)) continue;
      opts.add(d);
    }
    if (opts.isEmpty) return g.dir.opposite;
    return opts[_rng.nextInt(opts.length)];
  }

  bool _ghostBlocked(int x, int y, bool doorOpen) {
    if (_maze.isWallForGhost(x, y)) return true;
    if (_maze.isDoor(x, y)) return !doorOpen;
    return false;
  }

  Point<int> _scatterCorner(GhostType t) => switch (t) {
    GhostType.blinky => Point(_maze.width - 2, 0),
    GhostType.pinky => const Point(1, 0),
    GhostType.inky => Point(_maze.width - 2, _maze.height - 1),
    GhostType.clyde => Point(1, _maze.height - 1),
  };

  /// Objetivo de persecución según la personalidad del fantasma.
  Point<int> _targetFor(Ghost g) {
    final pacDir = _dir == PacDir.none ? PacDir.left : _dir;
    switch (g.type) {
      case GhostType.blinky:
        return Point(_tx, _ty);
      case GhostType.pinky:
        return Point(_tx + pacDir.vec.x * 4, _ty + pacDir.vec.y * 4);
      case GhostType.inky:
        final p2 = Point(_tx + pacDir.vec.x * 2, _ty + pacDir.vec.y * 2);
        final b = _ghosts.firstWhere((x) => x.type == GhostType.blinky,
            orElse: () => g);
        return Point(2 * p2.x - b.tx, 2 * p2.y - b.ty);
      case GhostType.clyde:
        final dx = (g.tx - _tx).toDouble();
        final dy = (g.ty - _ty).toDouble();
        return (dx * dx + dy * dy) > 64
            ? Point(_tx, _ty)
            : _scatterCorner(GhostType.clyde);
    }
  }

  // ---- Jefe ----------------------------------------------------------------

  void _stepBoss(double dtMs) {
    final b = _boss!;
    final now = _runWatch.elapsedMilliseconds;
    // Vulnerable (frightened) o reculando (cooldown) → más lento; si no,
    // persigue agresivo.
    final scale = (_frightenedMs > 0 || now < b.hitCooldownUntil) ? 0.6 : 0.95;
    var dist = _speed * scale * dtMs;
    while (dist > 0) {
      final toCenter = 1 - b.prog;
      if (dist < toCenter) {
        b.prog += dist;
        dist = 0;
      } else {
        dist -= toCenter;
        b.tx = _maze.wrapX(b.tx + b.dir.vec.x, b.ty);
        b.ty += b.dir.vec.y;
        b.prog = 0;
        b.dir = _chooseTowardBoss(b, Point(_tx, _ty));
        if (b.dir == PacDir.none) break;
      }
    }
  }

  PacDir _chooseTowardBoss(Boss b, Point<int> target) {
    var best = PacDir.none;
    var bestD = double.infinity;
    for (final d in const [PacDir.up, PacDir.left, PacDir.down, PacDir.right]) {
      if (d == b.dir.opposite) continue;
      final nx = _maze.wrapX(b.tx + d.vec.x, b.ty);
      final ny = b.ty + d.vec.y;
      if (ny < 0 || ny >= _maze.height) continue;
      if (_ghostBlocked(nx, ny, false)) continue;
      final ddx = (nx - target.x).toDouble();
      final ddy = (ny - target.y).toDouble();
      final dd = ddx * ddx + ddy * ddy;
      if (dd < bestD) {
        bestD = dd;
        best = d;
      }
    }
    return best == PacDir.none ? b.dir.opposite : best;
  }

  // ---- Colisiones ----------------------------------------------------------

  void _checkCollisions() {
    final px = _pacPxX();
    final py = _pacPxY();
    for (final g in _ghosts) {
      final dx = g.px - px;
      final dy = g.py - py;
      if (dx * dx + dy * dy >= 0.5 * 0.5) continue;
      if (g.mode == GhostMode.frightened) {
        _eatGhost(g);
      } else if (!_invuln &&
          (g.mode == GhostMode.scatter || g.mode == GhostMode.chase)) {
        _pacDies();
        return;
      }
    }

    // Jefe: vulnerable solo en frightened (embestirlo le quita vida); si no,
    // mortal al contacto. Tras un golpe queda inmune un instante (cooldown).
    final boss = _boss;
    if (boss != null) {
      final bdx = boss.px - px;
      final bdy = boss.py - py;
      if (bdx * bdx + bdy * bdy < 0.8 * 0.8) {
        final now = _runWatch.elapsedMilliseconds;
        if (now >= boss.hitCooldownUntil) {
          if (_frightenedMs > 0) {
            boss.hp--;
            _score += 500 * (_doubleActive ? 2 : 1);
            boss.hitCooldownUntil = now + 1200;
            boss.dir = boss.dir.opposite; // recula
            if (boss.hp <= 0) {
              _score += 2000 * (_doubleActive ? 2 : 1);
              _boss = null;
            }
          } else if (!_invuln) {
            _pacDies();
            return;
          }
        }
      }
    }
  }

  void _eatGhost(Ghost g) {
    _score += 200 * (1 << _ghostCombo) * (_doubleActive ? 2 : 1); // 200..1600
    if (_ghostCombo < 3) _ghostCombo++;
    g.mode = GhostMode.eaten;
  }

  void _pacDies() {
    // Escudo: absorbe el golpe y da una invulnerabilidad breve (sin perder vida).
    if (_shield) {
      _shield = false;
      _invulnUntil = _runWatch.elapsedMilliseconds + 1500;
      return;
    }
    _lives--;
    if (_lives <= 0) {
      _lose();
      return;
    }
    _frightenedMs = 0;
    _resetActors(); // recoloca a Pac y a los fantasmas + pausa de "listo"
  }

  // ---- Entrada -------------------------------------------------------------

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
    state = _snapshot(hasWon: true);
    _finish();
  }

  void _lose() {
    _timer?.cancel();
    state = _snapshot(hasLost: true);
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

  /// Construye el estado público desde los campos internos. Los argumentos
  /// permiten fijar valores de inicio/fin; el resto sale de los internos.
  PacmanGameState _snapshot({
    bool? isStarting,
    PacmanMaze? maze,
    int? gridWidth,
    int? gridHeight,
    int? level,
    int? targetScore,
    int? sessionId,
    bool? hasWon,
    bool? hasLost,
  }) {
    return state.copyWith(
      isStarting: isStarting,
      maze: maze,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      level: level,
      targetScore: targetScore,
      sessionId: sessionId,
      hasWon: hasWon,
      hasLost: hasLost,
      pacX: _pacPxX(),
      pacY: _pacPxY(),
      pacDir: _dir,
      mouth: _mouth,
      score: _score,
      pelletsEaten: _pellets,
      lives: _lives,
      ghosts: List<Ghost>.from(_ghosts),
      boss: () => _boss,
      frightenedMs: _frightenedMs,
      ready: _readyMs > 0,
      fruitActive: _fruitActive,
      fruitX: _fruitX,
      fruitY: _fruitY,
      powerups: List<PowerUp>.from(_powerups),
      speedActive: _speedActive,
      freezeActive: _freezeActive,
      doubleActive: _doubleActive,
      magnetActive: _magnetActive,
      shieldActive: _shield,
      invuln: _invuln,
      chainMult: _chainMult,
      frame: _frame,
    );
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

  /// Fantasmas (instantánea por frame; el repintado lo dispara [frame]).
  final List<Ghost> ghosts;

  /// Jefe (niveles 5 y 10); null si no hay o fue derrotado.
  final Boss? boss;

  final int frightenedMs;
  final bool ready;

  /// Fruta bonus (placeholder hasta tener sprite).
  final bool fruitActive;
  final int fruitX;
  final int fruitY;

  /// Power-ups en el laberinto y efectos activos (Fase 3).
  final List<PowerUp> powerups;
  final bool speedActive;
  final bool freezeActive;
  final bool doubleActive;
  final bool magnetActive;
  final bool shieldActive;
  final bool invuln;
  final int chainMult; // multiplicador de la cadena de pellets (1..5)

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
  /// aunque el laberinto/fantasmas se muten en sitio.
  final int frame;

  const PacmanGameState({
    this.maze,
    this.pacX = 0,
    this.pacY = 0,
    this.pacDir = PacDir.none,
    this.mouth = 0,
    this.ghosts = const [],
    this.boss,
    this.frightenedMs = 0,
    this.ready = false,
    this.fruitActive = false,
    this.fruitX = 0,
    this.fruitY = 0,
    this.powerups = const [],
    this.speedActive = false,
    this.freezeActive = false,
    this.doubleActive = false,
    this.magnetActive = false,
    this.shieldActive = false,
    this.invuln = false,
    this.chainMult = 1,
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
    List<Ghost>? ghosts,
    ValueGetter<Boss?>? boss,
    int? frightenedMs,
    bool? ready,
    bool? fruitActive,
    int? fruitX,
    int? fruitY,
    List<PowerUp>? powerups,
    bool? speedActive,
    bool? freezeActive,
    bool? doubleActive,
    bool? magnetActive,
    bool? shieldActive,
    bool? invuln,
    int? chainMult,
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
      ghosts: ghosts ?? this.ghosts,
      boss: boss != null ? boss() : this.boss,
      frightenedMs: frightenedMs ?? this.frightenedMs,
      ready: ready ?? this.ready,
      fruitActive: fruitActive ?? this.fruitActive,
      fruitX: fruitX ?? this.fruitX,
      fruitY: fruitY ?? this.fruitY,
      powerups: powerups ?? this.powerups,
      speedActive: speedActive ?? this.speedActive,
      freezeActive: freezeActive ?? this.freezeActive,
      doubleActive: doubleActive ?? this.doubleActive,
      magnetActive: magnetActive ?? this.magnetActive,
      shieldActive: shieldActive ?? this.shieldActive,
      invuln: invuln ?? this.invuln,
      chainMult: chainMult ?? this.chainMult,
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
    frightenedMs,
    ready,
    fruitActive,
    fruitX,
    fruitY,
    speedActive,
    freezeActive,
    doubleActive,
    magnetActive,
    shieldActive,
    invuln,
    chainMult,
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
