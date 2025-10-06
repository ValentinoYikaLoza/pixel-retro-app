class GetUserListResponseDto {
  bool success;
  String message;
  List<Datum> data;

  GetUserListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetUserListResponseDto.fromJson(Map<String, dynamic> json) =>
      GetUserListResponseDto(
        success: json["success"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String name;
  int score;
  int timesRankedFirst;
  String flag;

  Datum({
    required this.id,
    required this.name,
    required this.score,
    required this.timesRankedFirst,
    required this.flag,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    score: json["score"],
    timesRankedFirst: json["times_ranked_first"],
    flag: json["flag"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "score": score,
    "times_ranked_first": timesRankedFirst,
    "flag": flag,
  };
}
