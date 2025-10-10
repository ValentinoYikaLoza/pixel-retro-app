class Response {
  final String message;
  final bool success;

  Response({required this.message, required this.success});

  factory Response.fromJson(Map<String, dynamic> json) =>
      Response(message: json["msg"] ?? '', success: json["success"] ?? false);

  Map<String, dynamic> toJson() => {"message": message, "success": success};
}
