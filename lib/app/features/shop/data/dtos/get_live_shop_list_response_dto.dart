/// Respuesta de `GET /listLiveShop`.
/// Forma: `{ success, message, data: [{ id, quantity, price, type_id }] }`.
class GetLiveShopListResponseDto {
  final bool success;
  final String message;
  final List<LiveShopDto> data;

  GetLiveShopListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetLiveShopListResponseDto.fromJson(Map<String, dynamic> json) {
    return GetLiveShopListResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (e) => LiveShopDto.fromJson(e as Map<String, dynamic>? ?? const {}),
          )
          .toList(),
    );
  }
}

class LiveShopDto {
  final int id;
  final int quantity;
  final double price;
  final int typeId;

  LiveShopDto({
    required this.id,
    required this.quantity,
    required this.price,
    required this.typeId,
  });

  factory LiveShopDto.fromJson(Map<String, dynamic> json) {
    return LiveShopDto(
      id: json['id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      typeId: json['type_id'] as int? ?? 0,
    );
  }
}
