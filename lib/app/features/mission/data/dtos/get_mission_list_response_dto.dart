class GetMissionListResponseDto {
  bool success;
  String message;
  Data data;

  GetMissionListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetMissionListResponseDto.fromJson(Map<String, dynamic> json) =>
      GetMissionListResponseDto(
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
  List<LyMission> dailyMissions;
  List<LyMission> weeklyMissions;
  List<LyMission> monthlyMissions;

  Data({
    required this.dailyMissions,
    required this.weeklyMissions,
    required this.monthlyMissions,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    dailyMissions: List<LyMission>.from(
      json["dailyMissions"].map((x) => LyMission.fromJson(x)),
    ),
    weeklyMissions: List<LyMission>.from(
      json["weeklyMissions"].map((x) => LyMission.fromJson(x)),
    ),
    monthlyMissions: List<LyMission>.from(
      json["monthlyMissions"].map((x) => LyMission.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "dailyMissions": List<dynamic>.from(dailyMissions.map((x) => x.toJson())),
    "weeklyMissions": List<dynamic>.from(weeklyMissions.map((x) => x.toJson())),
    "monthlyMissions": List<dynamic>.from(
      monthlyMissions.map((x) => x.toJson()),
    ),
  };
}

class LyMission {
  int id;
  int currentValue;
  String description;
  int totalValue;
  int rewardId;
  int statusId;

  LyMission({
    required this.id,
    required this.currentValue,
    required this.description,
    required this.totalValue,
    required this.rewardId,
    required this.statusId,
  });

  factory LyMission.fromJson(Map<String, dynamic> json) => LyMission(
    id: json["id"],
    currentValue: json["current_value"],
    description: json["description"],
    totalValue: json["total_value"],
    rewardId: json["reward_id"],
    statusId: json["status_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "current_value": currentValue,
    "description": description,
    "total_value": totalValue,
    "reward_id": rewardId,
    "status_id": statusId,
  };
}
