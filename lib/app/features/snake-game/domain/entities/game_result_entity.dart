import 'package:equatable/equatable.dart';

/// Resultado de cerrar una partida (`finishGame`): lo que el servidor otorgó y
/// si se superó el nivel (desbloqueando el siguiente).
class GameResultEntity extends Equatable {
  final bool isHighScore;
  final int highScore;
  final int expGained;
  final int coinsGained;
  final bool levelCleared;
  final bool unlockedNext;

  const GameResultEntity({
    required this.isHighScore,
    required this.highScore,
    required this.expGained,
    required this.coinsGained,
    this.levelCleared = false,
    this.unlockedNext = false,
  });

  @override
  List<Object?> get props => [
    isHighScore,
    highScore,
    expGained,
    coinsGained,
    levelCleared,
    unlockedNext,
  ];
}
