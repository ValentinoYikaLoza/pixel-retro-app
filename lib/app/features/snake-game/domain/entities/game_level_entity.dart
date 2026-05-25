import 'dart:ui' show Offset;

import 'package:equatable/equatable.dart';

/// Un nivel del juego con su config (velocidad, grid, borde, paredes, objetivo)
/// y el progreso del usuario (mejor puntaje, superado, desbloqueado).
class GameLevelEntity extends Equatable {
  final int level;
  final int tickMs;
  final int gridWidth;
  final int gridHeight;
  final bool wrapAround;
  final List<Offset> walls;
  final int targetScore;
  final int bestScore;

  /// Mejor PUNTAJE real (score) logrado en el nivel — distinto de [bestScore],
  /// que es la métrica del objetivo (p. ej. pellets/líneas).
  final int bestPoints;
  final bool cleared;
  final bool unlocked;

  const GameLevelEntity({
    required this.level,
    required this.tickMs,
    required this.gridWidth,
    required this.gridHeight,
    required this.wrapAround,
    required this.walls,
    required this.targetScore,
    required this.bestScore,
    this.bestPoints = 0,
    required this.cleared,
    required this.unlocked,
  });

  @override
  List<Object?> get props => [
    level,
    tickMs,
    gridWidth,
    gridHeight,
    wrapAround,
    walls,
    targetScore,
    bestScore,
    bestPoints,
    cleared,
    unlocked,
  ];
}
