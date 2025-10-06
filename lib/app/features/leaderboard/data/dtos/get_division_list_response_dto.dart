class GetDivisionListResponseDto {
  bool success;
  String message;
  List<Datum> data;

  GetDivisionListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetDivisionListResponseDto.fromJson(Map<String, dynamic> json) =>
      GetDivisionListResponseDto(
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

  Datum({required this.id, required this.name});

  factory Datum.fromJson(Map<String, dynamic> json) =>
      Datum(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
