class GetTimeLeftResponseDto {
  bool success;
  String message;
  Data data;

  GetTimeLeftResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetTimeLeftResponseDto.fromJson(Map<String, dynamic> json) =>
      GetTimeLeftResponseDto(
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
  int time;
  String unit;

  Data({required this.time, required this.unit});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(time: json["time"], unit: json["unit"]);

  Map<String, dynamic> toJson() => {"time": time, "unit": unit};
}
