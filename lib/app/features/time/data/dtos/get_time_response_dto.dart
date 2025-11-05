class GetTimeResponseDto {
  bool success;
  String message;
  Data data;

  GetTimeResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetTimeResponseDto.fromJson(Map<String, dynamic> json) =>
      GetTimeResponseDto(
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
  DateTime time;

  Data({required this.time});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(time: DateTime.parse(json["time"]));

  Map<String, dynamic> toJson() => {"time": time.toIso8601String()};
}
