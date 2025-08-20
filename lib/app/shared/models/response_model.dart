class Response {
  final String message;
  final bool success;
  final int code;

  Response({required this.message, required this.success, required this.code});

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    message: json["msg"] ?? '',
    success: json["success"] ?? false,
    code: json["code"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "success": success,
    "code": code,
  };
}
