import 'package:equatable/equatable.dart';

/// Resultado de cerrar una partida (`finishGame`): lo que el servidor otorgó.
class GameResultEntity extends Equatable {
  final bool isHighScore;
  final int highScore;
  final int expGained;
  final int coinsGained;

  const GameResultEntity({
    required this.isHighScore,
    required this.highScore,
    required this.expGained,
    required this.coinsGained,
  });

  @override
  List<Object?> get props => [isHighScore, highScore, expGained, coinsGained];
}
