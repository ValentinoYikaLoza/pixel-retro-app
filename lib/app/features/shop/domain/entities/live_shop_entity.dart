import 'package:equatable/equatable.dart';

class LiveShopEntity extends Equatable {
  final int id;
  final int quantity;
  final double price;
  final int typeId;

  const LiveShopEntity({
    required this.id,
    required this.quantity,
    required this.price,
    required this.typeId,
  });

  @override
  List<Object?> get props => [id, quantity, price, typeId];
}
