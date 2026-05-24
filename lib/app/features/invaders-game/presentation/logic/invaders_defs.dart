import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

/// Resolución lógica del campo (portrait 0.7). El painter escala uniforme a la
/// pantalla, así que toda la lógica trabaja en estas unidades sin distorsión.
const double kFieldW = 280;
const double kFieldH = 400;

// Nave del jugador.
const double kShipW = 34;
const double kShipH = 14;
const double kShipY = kFieldH - 26; // centro vertical de la nave
const double kPlayerBulletSpeed = 430; // u/seg hacia arriba
const double kEnemyBulletSpeed = 190; // u/seg hacia abajo
const int kFireCooldownMs = 430; // disparo automático base
const int kRapidFireCooldownMs = 150;
const int kPowerUpMs = 7000; // duración de mejoras temporizadas
const int kComboWindowMs = 1500; // ventana para encadenar bajas
const int kStartShipLives = 3;
const int kMaxShipLives = 5;

// Invasores / formación.
const double kInvW = 20;
const double kInvH = 15;
const double kInvGapX = 30;
const double kInvGapY = 26;
const double kFormTop = 46; // y del borde superior de la formación
const double kFormStepDown = 14; // cuánto baja al rebotar
const double kFormStepX = 8; // salto horizontal por hop

/// Tipos de invasor: difieren en vida, puntos, color y comportamiento de
/// disparo. La variedad "veloz/zigzag" se expresa como picadas (dives).
enum EnemyType { normal, tank, sniper }

/// Estilo de picada cuando un invasor se separa de la formación.
enum DiveStyle { straight, zigzag }

enum PowerUpType { rapidFire, tripleShot, shield, extraLife }

int enemyHp(EnemyType t) => switch (t) {
  EnemyType.tank => 3,
  EnemyType.sniper => 2,
  EnemyType.normal => 1,
};

int enemyPoints(EnemyType t) => switch (t) {
  EnemyType.tank => 30,
  EnemyType.sniper => 25,
  EnemyType.normal => 10,
};

Color enemyColor(EnemyType t) => switch (t) {
  EnemyType.tank => AppColors.red,
  EnemyType.sniper => AppColors.neonPurple,
  EnemyType.normal => AppColors.emerald,
};

Color powerUpColor(PowerUpType t) => switch (t) {
  PowerUpType.rapidFire => AppColors.orange,
  PowerUpType.tripleShot => AppColors.yellow,
  PowerUpType.shield => const Color(0xFF4FC3F7),
  PowerUpType.extraLife => AppColors.red,
};

/// Letra que identifica al power-up en su cápsula.
String powerUpGlyph(PowerUpType t) => switch (t) {
  PowerUpType.rapidFire => 'R',
  PowerUpType.tripleShot => 'T',
  PowerUpType.shield => 'S',
  PowerUpType.extraLife => '+',
};

/// Un invasor con posición absoluta (en unidades de campo). Cuando `diving` es
/// true se mueve por su cuenta (picada) en vez de con la formación.
class Invader {
  Invader({
    required this.type,
    required this.x,
    required this.y,
    required this.hp,
  });

  EnemyType type;
  double x;
  double y;
  int hp;
  bool diving = false;
  DiveStyle diveStyle = DiveStyle.straight;
  double divePhase = 0; // para el zigzag
}

class Bullet {
  Bullet({required this.x, required this.y, required this.vy, this.vx = 0});
  double x;
  double y;
  double vy;
  double vx;
}

/// Celda de búnker con vida: cambia de sprite al recibir impactos (full → mid →
/// broken) y desaparece al llegar a 0.
class BunkerCell {
  BunkerCell(this.x, this.y, [this.hp = 3]);
  final double x;
  final double y;
  int hp;
}

class PowerUp {
  PowerUp({required this.type, required this.x, required this.y});
  final PowerUpType type;
  double x;
  double y;
}

/// OVNI bonus que cruza la parte superior.
class Ufo {
  Ufo({required this.x, required this.vx, required this.points});
  double x;
  final double vx;
  final int points;
}

/// Jefe (niveles múltiplos de 5): se mueve de lado a lado y dispara en abanico.
class Boss {
  Boss({required this.x, required this.hp, required this.maxHp});
  double x;
  double y = 60;
  double dir = 1;
  int hp;
  final int maxHp;
  int fireAccumMs = 0;
}

/// Configuración derivada del número de nivel (no vive en la BD para no tocar el
/// esquema; el backend solo aporta velocidad, búnkeres y meta).
class LevelPlan {
  LevelPlan({
    required this.cols,
    required this.rows,
    required this.fireRateMs,
    required this.diveChancePerSec,
    required this.hasBoss,
    required this.bossWave,
  });

  final int cols;
  final int rows;
  final int fireRateMs;
  final double diveChancePerSec;
  final bool hasBoss;
  final int bossWave;

  factory LevelPlan.forLevel(int level) {
    return LevelPlan(
      cols: (5 + level ~/ 3).clamp(5, 8),
      rows: (3 + level ~/ 4).clamp(3, 5),
      fireRateMs: (1400 - level * 90).clamp(450, 1400),
      diveChancePerSec: (0.05 + level * 0.05).clamp(0.0, 0.6),
      hasBoss: level % 5 == 0,
      bossWave: 2,
    );
  }

  /// Tipo de invasor según su fila (0 = arriba, más duros arriba).
  EnemyType typeForRow(int row, int level) {
    if (row == 0 && level >= 4) return EnemyType.tank;
    if (row == 0 && level >= 2) return EnemyType.sniper;
    if (row == 1 && level >= 6) return EnemyType.sniper;
    return EnemyType.normal;
  }
}
