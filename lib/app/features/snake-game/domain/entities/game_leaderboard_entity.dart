import 'package:equatable/equatable.dart';

/// Tabla de líderes por juego (`getGameLeaderboard`): top por mejor puntaje más
/// el resumen del propio usuario.
class GameLeaderboardEntity extends Equatable {
  final List<GameLeaderboardEntryEntity> entries;
  final int myHighScore;
  final int myTotalGames;
  final int myTotalScore;

  const GameLeaderboardEntity({
    this.entries = const [],
    this.myHighScore = 0,
    this.myTotalGames = 0,
    this.myTotalScore = 0,
  });

  @override
  List<Object?> get props => [entries, myHighScore, myTotalGames, myTotalScore];
}

class GameLeaderboardEntryEntity extends Equatable {
  final int userId;
  final String name;
  final int highScore;
  final int totalGames;
  final String flag;

  const GameLeaderboardEntryEntity({
    required this.userId,
    required this.name,
    required this.highScore,
    required this.totalGames,
    required this.flag,
  });

  @override
  List<Object?> get props => [userId, name, highScore, totalGames, flag];
}
