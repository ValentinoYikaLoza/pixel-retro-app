class GetCurrentDivisionResponseDto {
  bool success;
  String message;
  Data data;

  GetCurrentDivisionResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetCurrentDivisionResponseDto.fromJson(Map<String, dynamic> json) =>
      GetCurrentDivisionResponseDto(
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

  Data({required this.id, required this.name});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
