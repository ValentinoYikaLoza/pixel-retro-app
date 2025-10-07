class GetCurrentMonthResponseDto {
  bool success;
  String message;
  int data;

  GetCurrentMonthResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetCurrentMonthResponseDto.fromJson(Map<String, dynamic> json) =>
      GetCurrentMonthResponseDto(
        success: json["success"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data,
  };
}
