import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/data/shop_items_data.dart';

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});

class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier(this.ref) : super(ShopState());

  final Ref ref;

  void initShopItems() {
    final List<ShopItemModel> shopItems = shopItemsData;

    final List<ShopItemModel> monedasItems = shopItems
        .where((item) => item.category == ShopItemCategory.monedas)
        .toList();

    final List<ShopItemModel> vidasItemsUnitCoin = shopItems
        .where(
          (item) =>
              item.category == ShopItemCategory.vidas &&
              item.unit == ShopItemUnit.coins,
        )
        .toList();

    final List<ShopItemModel> vidasItemsUnitUsd = shopItems
        .where(
          (item) =>
              item.category == ShopItemCategory.vidas &&
              item.unit == ShopItemUnit.usd,
        )
        .toList();

    state = state.copyWith(
      shopMonedasItems: monedasItems,
      shopVidasItemsUnitCoin: vidasItemsUnitCoin,
      shopVidasItemsUnitUsd: vidasItemsUnitUsd,
    );
  }
}

class ShopState {
  final List<ShopItemModel> shopMonedasItems;
  final List<ShopItemModel> shopVidasItemsUnitCoin;
  final List<ShopItemModel> shopVidasItemsUnitUsd;

  ShopState({
    this.shopMonedasItems = const [],
    this.shopVidasItemsUnitCoin = const [],
    this.shopVidasItemsUnitUsd = const [],
  });

  ShopState copyWith({
    List<ShopItemModel>? shopMonedasItems,
    List<ShopItemModel>? shopVidasItemsUnitCoin,
    List<ShopItemModel>? shopVidasItemsUnitUsd,
  }) {
    return ShopState(
      shopMonedasItems: shopMonedasItems ?? this.shopMonedasItems,
      shopVidasItemsUnitCoin:
          shopVidasItemsUnitCoin ?? this.shopVidasItemsUnitCoin,
      shopVidasItemsUnitUsd:
          shopVidasItemsUnitUsd ?? this.shopVidasItemsUnitUsd,
    );
  }
}

enum ShopItemCategory { monedas, vidas }

enum ShopItemUnit { coins, usd }

enum AdViewStatus { claimed, unclaimed }

class ShopItemModel {
  final String id;
  final int quantity;
  final double price;
  final String imagePath;
  final ShopItemUnit unit;
  final ShopItemCategory category;

  ShopItemModel({
    required this.id,
    required this.quantity,
    required this.price,
    required this.imagePath,
    required this.unit,
    required this.category,
  });
}
