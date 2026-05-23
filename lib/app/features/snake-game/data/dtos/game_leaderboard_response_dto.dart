/// Respuesta de `POST /getGameLeaderboard`.
/// Forma: `{ success, message, data: { leaderboard: [{ user_id, name,
/// high_score, total_games, flag }], me: { high_score, total_games,
/// total_score } } }`. Parseo defensivo.
class GameLeaderboardResponseDto {
  final bool success;
  final String message;
  final List<GameLeaderboardEntryDto> leaderboard;
  final GameLeaderboardMeDto me;

  GameLeaderboardResponseDto({
    required this.success,
    required this.message,
    required this.leaderboard,
    required this.me,
  });

  factory GameLeaderboardResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return GameLeaderboardResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      leaderboard: (data['leaderboard'] as List<dynamic>? ?? [])
          .map(
            (e) => GameLeaderboardEntryDto.fromJson(
              e as Map<String, dynamic>? ?? const {},
            ),
          )
          .toList(),
      me: GameLeaderboardMeDto.fromJson(
        data['me'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class GameLeaderboardEntryDto {
  final int userId;
  final String name;
  final int highScore;
  final int totalGames;
  final String flag;

  GameLeaderboardEntryDto({
    required this.userId,
    required this.name,
    required this.highScore,
    required this.totalGames,
    required this.flag,
  });

  factory GameLeaderboardEntryDto.fromJson(Map<String, dynamic> json) {
    return GameLeaderboardEntryDto(
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      highScore: (json['high_score'] as num?)?.toInt() ?? 0,
      totalGames: (json['total_games'] as num?)?.toInt() ?? 0,
      flag: json['flag']?.toString() ?? '',
    );
  }
}

class GameLeaderboardMeDto {
  final int highScore;
  final int totalGames;
  final int totalScore;

  GameLeaderboardMeDto({
    required this.highScore,
    required this.totalGames,
    required this.totalScore,
  });

  factory GameLeaderboardMeDto.fromJson(Map<String, dynamic> json) {
    return GameLeaderboardMeDto(
      highScore: (json['high_score'] as num?)?.toInt() ?? 0,
      totalGames: (json['total_games'] as num?)?.toInt() ?? 0,
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
    );
  }
}
