/// Respuesta de `GET /listCoinShop`.
/// Forma: `{ success, message, data: [{ id, quantity, price }] }`.
class GetCoinShopListResponseDto {
  final bool success;
  final String message;
  final List<CoinShopDto> data;

  GetCoinShopListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetCoinShopListResponseDto.fromJson(Map<String, dynamic> json) {
    return GetCoinShopListResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (e) => CoinShopDto.fromJson(e as Map<String, dynamic>? ?? const {}),
          )
          .toList(),
    );
  }
}

class CoinShopDto {
  final int id;
  final int quantity;
  final double price;

  CoinShopDto({required this.id, required this.quantity, required this.price});

  factory CoinShopDto.fromJson(Map<String, dynamic> json) {
    return CoinShopDto(
      id: json['id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
