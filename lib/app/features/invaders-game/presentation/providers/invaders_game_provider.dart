import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_defs.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/entities/game_result_entity.dart';
import 'package:pixel_retro_app/app/features/snake-game/domain/repositories/snake_game_repository.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/di.dart';

const String _invadersGameCode = 'invaders';
const int _loopMs = 20; // ~50 fps

final invadersGameProvider =
    StateNotifierProvider.autoDispose<InvadersGameNotifier, InvadersGameState>((
      ref,
    ) {
      return InvadersGameNotifier(ref);
    });

class InvadersGameNotifier extends StateNotifier<InvadersGameState> {
  InvadersGameNotifier(this.ref) : super(const InvadersGameState());

  final Ref ref;
  final SnakeGameRepository _repository = getIt<SnakeGameRepository>();

  Timer? _timer;
  Random _rng = Random();
  final Stopwatch _runWatch = Stopwatch();

  int? _sessionId;
  bool _closed = false;

  // Mundo (mutado en sitio cada frame; el estado solo referencia las listas).
  final List<Invader> _invaders = [];
  final List<Bullet> _pBullets = [];
  final List<Bullet> _eBullets = [];
  final List<PowerUp> _powerups = [];
  final List<Offset> _bunkers = [];
  Ufo? _ufo;
  Boss? _boss;

  double _bunkerCell = 0;
  double _shipX = kFieldW / 2;
  int _shipLives = kStartShipLives;
  int _score = 0;
  int _kills = 0;
  int _wave = 1;
  int _combo = 0;
  int _frame = 0;

  late LevelPlan _plan;
  int _baseStepMs = 500;
  int _targetScore = 0;
  int _gridW = 24;
  int _gridH = 24;

  // Acumuladores / temporizadores (ms).
  int _hopAccum = 0;
  int _dir = 1; // dirección de la formación
  int _fireAccum = 0; // disparo enemigo
  int _shootAccum = 0; // disparo del jugador (auto-fire)
  int _ufoAccum = 0;

  // Mejoras temporizadas (deadline en ms del cronómetro de la partida).
  int _rapidUntil = 0;
  int _tripleUntil = 0;
  int _shieldUntil = 0;
  int _comboUntil = 0;

  bool get _rapid => _runWatch.elapsedMilliseconds < _rapidUntil;
  bool get _triple => _runWatch.elapsedMilliseconds < _tripleUntil;
  bool get _shield => _runWatch.elapsedMilliseconds < _shieldUntil;

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
      final session = await _repository.startGame(_invadersGameCode, level);

      _sessionId = session.sessionId;
      _rng = Random(session.seed);
      _runWatch
        ..reset()
        ..start();
      _closed = false;
      _gridW = session.gridWidth;
      _gridH = session.gridHeight;
      _baseStepMs = session.tickMs;
      _targetScore = session.targetScore;
      _plan = LevelPlan.forLevel(session.level);

      _shipX = kFieldW / 2;
      _shipLives = kStartShipLives;
      _score = 0;
      _kills = 0;
      _wave = 1;
      _combo = 0;
      _frame = 0;
      _hopAccum = 0;
      _dir = 1;
      _fireAccum = 0;
      _shootAccum = 0;
      _ufoAccum = 0;
      _rapidUntil = _tripleUntil = _shieldUntil = _comboUntil = 0;
      _pBullets.clear();
      _eBullets.clear();
      _powerups.clear();
      _ufo = null;
      _boss = null;

      _buildBunkers(session.walls);
      _spawnWave();

      state = InvadersGameState(
        isStarting: false,
        level: session.level,
        targetScore: _targetScore,
        wave: _wave,
        score: 0,
        kills: 0,
        shipLives: _shipLives,
        shipX: _shipX,
        invaders: _invaders,
        playerBullets: _pBullets,
        enemyBullets: _eBullets,
        powerups: _powerups,
        bunkers: _bunkers,
        bunkerCell: _bunkerCell,
        sessionId: session.sessionId,
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

  /// Búnkeres: cada celda de `walls` (grid del nivel) a coordenadas de campo.
  void _buildBunkers(List<Offset> walls) {
    _bunkers.clear();
    _bunkerCell = kFieldW / _gridW;
    for (final c in walls) {
      _bunkers.add(
        Offset((c.dx + 0.5) / _gridW * kFieldW, (c.dy + 0.5) / _gridH * kFieldH),
      );
    }
  }

  /// Crea la formación de la oleada actual (o el jefe en su oleada).
  void _spawnWave() {
    _invaders.clear();
    _hopAccum = 0;
    _dir = 1;

    if (_plan.hasBoss && _wave == _plan.bossWave) {
      final hp = 30 + state.level * 4;
      _boss = Boss(x: kFieldW / 2, hp: hp, maxHp: hp);
      return;
    }

    final cols = _plan.cols;
    final rows = _plan.rows;
    final formW = (cols - 1) * kInvGapX;
    final startX = (kFieldW - formW) / 2;
    final top = kFormTop + (_wave - 1) * 8; // oleadas siguientes empiezan más abajo

    for (var r = 0; r < rows; r++) {
      final type = _plan.typeForRow(r, state.level);
      for (var c = 0; c < cols; c++) {
        _invaders.add(
          Invader(
            type: type,
            x: startX + c * kInvGapX,
            y: top + r * kInvGapY,
            hp: enemyHp(type),
          ),
        );
      }
    }
  }

  // ---- Bucle ---------------------------------------------------------------

  void _loop() {
    if (state.hasLost || state.isPaused) return;
    const dtMs = _loopMs;
    const dt = _loopMs / 1000.0;

    _updateBullets(dt);
    _updatePowerups(dt);
    _updateUfo(dtMs, dt);
    _maybeSpawnDive(dt);
    _updateDivers(dt);
    if (_boss != null) {
      _updateBoss(dtMs, dt);
    } else {
      _hopFormation(dtMs);
      _enemyFire(dtMs);
    }
    _autoFire(dtMs);
    _collisions();
    _comboTick(dtMs);
    _checkWaveAndEnd();

    _frame++;
    state = state.copyWith(
      frame: _frame,
      score: _score,
      kills: _kills,
      shipLives: _shipLives,
      shipX: _shipX,
      wave: _wave,
      combo: _combo,
      rapidActive: _rapid,
      tripleActive: _triple,
      shieldActive: _shield,
      boss: () => _boss,
      ufo: () => _ufo,
    );
  }

  void _updateBullets(double dt) {
    for (final b in _pBullets) {
      b.y += b.vy * dt;
      b.x += b.vx * dt;
    }
    for (final b in _eBullets) {
      b.y += b.vy * dt;
      b.x += b.vx * dt;
    }
    _pBullets.removeWhere((b) => b.y < -20 || b.x < -20 || b.x > kFieldW + 20);
    _eBullets.removeWhere((b) => b.y > kFieldH + 20);
  }

  void _updatePowerups(double dt) {
    for (final p in _powerups) {
      p.y += 90 * dt;
    }
    _powerups.removeWhere((p) => p.y > kFieldH + 20);
  }

  void _updateUfo(int dtMs, double dt) {
    final ufo = _ufo;
    if (ufo != null) {
      ufo.x += ufo.vx * dt;
      if (ufo.x < -30 || ufo.x > kFieldW + 30) _ufo = null;
      return;
    }
    _ufoAccum += dtMs;
    if (_ufoAccum > 11000 && _rng.nextDouble() < 0.02) {
      _ufoAccum = 0;
      final fromLeft = _rng.nextBool();
      final pts = [50, 100, 150][_rng.nextInt(3)];
      _ufo = Ufo(
        x: fromLeft ? -20 : kFieldW + 20,
        vx: (fromLeft ? 1 : -1) * 80,
        points: pts,
      );
    }
  }

  void _maybeSpawnDive(double dt) {
    if (_rng.nextDouble() >= _plan.diveChancePerSec * dt) return;
    final candidates = _invaders.where((i) => !i.diving).toList();
    if (candidates.isEmpty) return;
    final inv = candidates[_rng.nextInt(candidates.length)];
    inv.diving = true;
    inv.diveStyle = _rng.nextBool() ? DiveStyle.zigzag : DiveStyle.straight;
    inv.divePhase = 0;
  }

  void _updateDivers(double dt) {
    for (final inv in _invaders) {
      if (!inv.diving) continue;
      inv.y += 150 * dt;
      if (inv.diveStyle == DiveStyle.zigzag) {
        inv.divePhase += dt * 6;
        inv.x += sin(inv.divePhase) * 70 * dt;
      } else {
        // Persigue ligeramente al jugador.
        inv.x += (_shipX - inv.x).clamp(-50, 50) * dt;
      }
    }
    _invaders.removeWhere((i) => i.diving && i.y > kFieldH + 10);
  }

  void _hopFormation(int dtMs) {
    final alive = _invaders.where((i) => !i.diving).toList();
    if (alive.isEmpty) return;

    final total = _plan.cols * _plan.rows;
    final aliveFrac = (_invaders.length / total).clamp(0.05, 1.0);
    final waveScale = pow(0.9, _wave - 1).toDouble();
    final interval = (_baseStepMs * waveScale * (0.3 + 0.7 * aliveFrac))
        .clamp(90, 2000)
        .toInt();

    _hopAccum += dtMs;
    if (_hopAccum < interval) return;
    _hopAccum = 0;

    var minX = kFieldW, maxX = 0.0;
    for (final i in alive) {
      minX = min(minX, i.x);
      maxX = max(maxX, i.x);
    }

    final dx = _dir * kFormStepX;
    if (minX + dx < kInvW / 2 + 2 || maxX + dx > kFieldW - kInvW / 2 - 2) {
      for (final i in alive) {
        i.y += kFormStepDown;
      }
      _dir = -_dir;
      // Invasión: la formación llegó a la nave.
      if (alive.any((i) => i.y + kInvH / 2 >= kShipY - kShipH)) {
        _lose();
      }
    } else {
      for (final i in alive) {
        i.x += dx;
      }
    }
  }

  void _enemyFire(int dtMs) {
    _fireAccum += dtMs;
    if (_fireAccum < _plan.fireRateMs) return;
    _fireAccum = 0;
    final alive = _invaders.where((i) => !i.diving).toList();
    if (alive.isEmpty) return;

    // El más bajo de una columna al azar.
    final shooter = alive[_rng.nextInt(alive.length)];
    double vx = 0;
    if (shooter.type == EnemyType.sniper) {
      final dxToShip = (_shipX - shooter.x);
      vx = dxToShip.clamp(-90, 90).toDouble();
    }
    _eBullets.add(
      Bullet(x: shooter.x, y: shooter.y + kInvH / 2, vy: kEnemyBulletSpeed, vx: vx),
    );
  }

  void _autoFire(int dtMs) {
    _shootAccum += dtMs;
    final cooldown = _rapid ? kRapidFireCooldownMs : kFireCooldownMs;
    if (_shootAccum < cooldown) return;
    _shootAccum = 0;
    final topY = kShipY - kShipH;
    if (_triple) {
      _pBullets
        ..add(Bullet(x: _shipX, y: topY, vy: -kPlayerBulletSpeed))
        ..add(Bullet(x: _shipX, y: topY, vy: -kPlayerBulletSpeed, vx: -120))
        ..add(Bullet(x: _shipX, y: topY, vy: -kPlayerBulletSpeed, vx: 120));
    } else {
      _pBullets.add(Bullet(x: _shipX, y: topY, vy: -kPlayerBulletSpeed));
    }
  }

  void _updateBoss(int dtMs, double dt) {
    final boss = _boss!;
    boss.x += boss.dir * 60 * dt;
    if (boss.x < 40) {
      boss.x = 40;
      boss.dir = 1;
    } else if (boss.x > kFieldW - 40) {
      boss.x = kFieldW - 40;
      boss.dir = -1;
    }
    boss.fireAccumMs += dtMs;
    if (boss.fireAccumMs >= 1100) {
      boss.fireAccumMs = 0;
      for (final vx in [-90.0, -45.0, 0.0, 45.0, 90.0]) {
        _eBullets.add(
          Bullet(x: boss.x, y: boss.y + 18, vy: kEnemyBulletSpeed, vx: vx),
        );
      }
    }
  }

  // ---- Colisiones ----------------------------------------------------------

  bool _hit(double ax, double ay, double aw, double ah, double bx, double by, double bw, double bh) {
    return (ax - aw / 2 < bx + bw / 2) &&
        (ax + aw / 2 > bx - bw / 2) &&
        (ay - ah / 2 < by + bh / 2) &&
        (ay + ah / 2 > by - bh / 2);
  }

  void _collisions() {
    // Balas del jugador.
    _pBullets.removeWhere((b) {
      // Búnker.
      for (var k = 0; k < _bunkers.length; k++) {
        final c = _bunkers[k];
        if (_hit(b.x, b.y, 3, 12, c.dx, c.dy, _bunkerCell, _bunkerCell)) {
          _bunkers.removeAt(k);
          return true;
        }
      }
      // OVNI.
      final ufo = _ufo;
      if (ufo != null && _hit(b.x, b.y, 3, 12, ufo.x, 24, 28, 14)) {
        _score += ufo.points;
        _ufo = null;
        return true;
      }
      // Jefe.
      final boss = _boss;
      if (boss != null && _hit(b.x, b.y, 3, 12, boss.x, boss.y, 60, 34)) {
        boss.hp -= 1;
        if (boss.hp <= 0) {
          _score += 500 + state.level * 50;
          _kills += 1;
          _boss = null;
        }
        return true;
      }
      // Invasores.
      for (final inv in _invaders) {
        if (_hit(b.x, b.y, 3, 12, inv.x, inv.y, kInvW, kInvH)) {
          inv.hp -= 1;
          if (inv.hp <= 0) _killInvader(inv);
          return true;
        }
      }
      return false;
    });
    _invaders.removeWhere((i) => i.hp <= 0);

    // Balas enemigas vs nave / búnker.
    _eBullets.removeWhere((b) {
      for (var k = 0; k < _bunkers.length; k++) {
        final c = _bunkers[k];
        if (_hit(b.x, b.y, 4, 12, c.dx, c.dy, _bunkerCell, _bunkerCell)) {
          _bunkers.removeAt(k);
          return true;
        }
      }
      if (_hit(b.x, b.y, 4, 12, _shipX, kShipY, kShipW, kShipH)) {
        _damageShip();
        return true;
      }
      return false;
    });

    // Picadas vs nave.
    for (final inv in _invaders) {
      if (inv.diving && _hit(inv.x, inv.y, kInvW, kInvH, _shipX, kShipY, kShipW, kShipH)) {
        inv.hp = 0;
        _damageShip();
      }
    }
    _invaders.removeWhere((i) => i.hp <= 0);

    // Power-ups vs nave.
    _powerups.removeWhere((p) {
      if (_hit(p.x, p.y, 16, 16, _shipX, kShipY, kShipW, kShipH)) {
        _applyPowerUp(p.type);
        return true;
      }
      return false;
    });
  }

  void _killInvader(Invader inv) {
    _kills += 1;
    _combo += 1;
    _comboUntil = _runWatch.elapsedMilliseconds + kComboWindowMs;
    final mult = (1 + _combo * 0.1).clamp(1.0, 3.0);
    _score += (enemyPoints(inv.type) * mult).round();
    // Drop de power-up.
    if (_rng.nextDouble() < 0.12) {
      final type = PowerUpType.values[_rng.nextInt(PowerUpType.values.length)];
      _powerups.add(PowerUp(type: type, x: inv.x, y: inv.y));
    }
  }

  void _damageShip() {
    if (_shield) return; // el escudo absorbe
    _shipLives -= 1;
    if (_shipLives <= 0) {
      _lose();
    }
  }

  void _applyPowerUp(PowerUpType type) {
    final now = _runWatch.elapsedMilliseconds;
    switch (type) {
      case PowerUpType.rapidFire:
        _rapidUntil = now + kPowerUpMs;
      case PowerUpType.tripleShot:
        _tripleUntil = now + kPowerUpMs;
      case PowerUpType.shield:
        _shieldUntil = now + kPowerUpMs;
      case PowerUpType.extraLife:
        _shipLives = min(kMaxShipLives, _shipLives + 1);
    }
  }

  void _comboTick(int dtMs) {
    if (_combo > 0 && _runWatch.elapsedMilliseconds > _comboUntil) {
      _combo = 0;
    }
  }

  void _checkWaveAndEnd() {
    if (state.hasLost) return;

    // Ganó: alcanzó la meta de puntos.
    if (_score >= _targetScore) {
      _lose(); // termina la partida; el backend marca levelCleared (score>=target)
      return;
    }

    // Oleada limpia → siguiente.
    final noEnemies = _invaders.isEmpty && _boss == null;
    if (noEnemies) {
      _wave += 1;
      _spawnWave();
    }
  }

  // ---- Controles -----------------------------------------------------------

  /// Mueve la nave a una fracción horizontal del campo (0..1) según el arrastre.
  void moveShipTo(double fraction) {
    if (state.hasLost || state.isPaused) return;
    _shipX = (fraction * kFieldW).clamp(kShipW / 2, kFieldW - kShipW / 2);
    state = state.copyWith(shipX: _shipX);
  }

  void togglePause() {
    if (state.hasLost) return;
    final pausing = !state.isPaused;
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

  // ---- Servidor ------------------------------------------------------------

  void _lose() {
    _timer?.cancel();
    state = state.copyWith(hasLost: true);
    _finish();
  }

  Future<void> _finish() async {
    final sessionId = _sessionId;
    if (_closed || sessionId == null) return;
    _closed = true;

    final durationMs = _runWatch.elapsedMilliseconds;
    state = state.copyWith(isSubmitting: true);
    try {
      final result = await _repository.finishGame(
        sessionId: sessionId,
        score: _score,
        foodEaten: _kills, // métrica secundaria = invasores eliminados
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

class InvadersGameState extends Equatable {
  final int frame;
  final int level;
  final int targetScore;
  final int wave;
  final int score;
  final int kills;
  final int shipLives;
  final double shipX;
  final int combo;

  final bool rapidActive;
  final bool tripleActive;
  final bool shieldActive;

  final List<Invader> invaders;
  final List<Bullet> playerBullets;
  final List<Bullet> enemyBullets;
  final List<PowerUp> powerups;
  final List<Offset> bunkers;
  final double bunkerCell;
  final Ufo? ufo;
  final Boss? boss;

  final bool hasLost;
  final bool isPaused;
  final int? sessionId;
  final bool isStarting;
  final bool startFailed;
  final String? startError;
  final bool isSubmitting;
  final GameResultEntity? result;

  const InvadersGameState({
    this.frame = 0,
    this.level = 1,
    this.targetScore = 0,
    this.wave = 1,
    this.score = 0,
    this.kills = 0,
    this.shipLives = kStartShipLives,
    this.shipX = kFieldW / 2,
    this.combo = 0,
    this.rapidActive = false,
    this.tripleActive = false,
    this.shieldActive = false,
    this.invaders = const [],
    this.playerBullets = const [],
    this.enemyBullets = const [],
    this.powerups = const [],
    this.bunkers = const [],
    this.bunkerCell = 0,
    this.ufo,
    this.boss,
    this.hasLost = false,
    this.isPaused = false,
    this.sessionId,
    this.isStarting = false,
    this.startFailed = false,
    this.startError,
    this.isSubmitting = false,
    this.result,
  });

  InvadersGameState copyWith({
    int? frame,
    int? level,
    int? targetScore,
    int? wave,
    int? score,
    int? kills,
    int? shipLives,
    double? shipX,
    int? combo,
    bool? rapidActive,
    bool? tripleActive,
    bool? shieldActive,
    List<Invader>? invaders,
    List<Bullet>? playerBullets,
    List<Bullet>? enemyBullets,
    List<PowerUp>? powerups,
    List<Offset>? bunkers,
    double? bunkerCell,
    ValueGetter<Ufo?>? ufo,
    ValueGetter<Boss?>? boss,
    bool? hasLost,
    bool? isPaused,
    int? sessionId,
    bool? isStarting,
    bool? startFailed,
    ValueGetter<String?>? startError,
    bool? isSubmitting,
    ValueGetter<GameResultEntity?>? result,
  }) {
    return InvadersGameState(
      frame: frame ?? this.frame,
      level: level ?? this.level,
      targetScore: targetScore ?? this.targetScore,
      wave: wave ?? this.wave,
      score: score ?? this.score,
      kills: kills ?? this.kills,
      shipLives: shipLives ?? this.shipLives,
      shipX: shipX ?? this.shipX,
      combo: combo ?? this.combo,
      rapidActive: rapidActive ?? this.rapidActive,
      tripleActive: tripleActive ?? this.tripleActive,
      shieldActive: shieldActive ?? this.shieldActive,
      invaders: invaders ?? this.invaders,
      playerBullets: playerBullets ?? this.playerBullets,
      enemyBullets: enemyBullets ?? this.enemyBullets,
      powerups: powerups ?? this.powerups,
      bunkers: bunkers ?? this.bunkers,
      bunkerCell: bunkerCell ?? this.bunkerCell,
      ufo: ufo != null ? ufo() : this.ufo,
      boss: boss != null ? boss() : this.boss,
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
    frame,
    level,
    targetScore,
    wave,
    score,
    kills,
    shipLives,
    shipX,
    combo,
    rapidActive,
    tripleActive,
    shieldActive,
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
