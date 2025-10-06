class GetUserResponseDto {
  bool success;
  String message;
  Data data;

  GetUserResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetUserResponseDto.fromJson(Map<String, dynamic> json) =>
      GetUserResponseDto(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  int id;
  String name;
  int coins;
  int lives;
  int score;
  int streak;

  Data({
    required this.id,
    required this.name,
    required this.coins,
    required this.lives,
    required this.score,
    required this.streak,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    coins: json["coins"],
    lives: json["lives"],
    score: json["score"],
    streak: json["streak"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "coins": coins,
    "lives": lives,
    "score": score,
    "streak": streak,
  };
}
