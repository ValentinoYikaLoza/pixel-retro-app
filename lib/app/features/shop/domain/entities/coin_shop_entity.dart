import 'package:equatable/equatable.dart';

class CoinShopEntity extends Equatable {
  final int id;
  final int quantity;
  final double price;

  const CoinShopEntity({
    required this.id,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [id, quantity, price];
}
