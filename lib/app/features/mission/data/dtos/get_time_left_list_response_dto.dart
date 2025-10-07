class GetTimeLeftListResponseDto {
  bool success;
  String message;
  Data data;

  GetTimeLeftListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetTimeLeftListResponseDto.fromJson(Map<String, dynamic> json) =>
      GetTimeLeftListResponseDto(
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
  TimeLeftUntilNext timeLeftUntilNextDay;
  TimeLeftUntilNext timeLeftUntilNextWeek;
  TimeLeftUntilNext timeLeftUntilNextMonth;

  Data({
    required this.timeLeftUntilNextDay,
    required this.timeLeftUntilNextWeek,
    required this.timeLeftUntilNextMonth,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    timeLeftUntilNextDay: TimeLeftUntilNext.fromJson(
      json["timeLeftUntilNextDay"],
    ),
    timeLeftUntilNextWeek: TimeLeftUntilNext.fromJson(
      json["timeLeftUntilNextWeek"],
    ),
    timeLeftUntilNextMonth: TimeLeftUntilNext.fromJson(
      json["timeLeftUntilNextMonth"],
    ),
  );

  Map<String, dynamic> toJson() => {
    "timeLeftUntilNextDay": timeLeftUntilNextDay.toJson(),
    "timeLeftUntilNextWeek": timeLeftUntilNextWeek.toJson(),
    "timeLeftUntilNextMonth": timeLeftUntilNextMonth.toJson(),
  };
}

class TimeLeftUntilNext {
  int time;
  String unit;

  TimeLeftUntilNext({required this.time, required this.unit});

  factory TimeLeftUntilNext.fromJson(Map<String, dynamic> json) =>
      TimeLeftUntilNext(time: json["time"], unit: json["unit"]);

  Map<String, dynamic> toJson() => {"time": time, "unit": unit};
}
