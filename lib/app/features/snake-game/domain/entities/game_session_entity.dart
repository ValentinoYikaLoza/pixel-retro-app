import 'package:equatable/equatable.dart';

/// Sesión de partida abierta por el servidor (`startGame`). El cliente la usa
/// para jugar de forma reproducible: `seed` siembra el RNG de la comida y la
/// config (tick/grid) reemplaza los valores antes hardcodeados.
class GameSessionEntity extends Equatable {
  final int sessionId;
  final int seed;
  final int tickMs;
  final int gridWidth;
  final int gridHeight;
  final int livesLeft;

  const GameSessionEntity({
    required this.sessionId,
    required this.seed,
    required this.tickMs,
    required this.gridWidth,
    required this.gridHeight,
    required this.livesLeft,
  });

  @override
  List<Object?> get props => [
    sessionId,
    seed,
    tickMs,
    gridWidth,
    gridHeight,
    livesLeft,
  ];
}
