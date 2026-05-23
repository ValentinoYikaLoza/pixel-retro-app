import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/coin_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/live_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/repositories/shop_repository.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/di.dart';

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});

/// Carga los datos de la tienda (se recarga al re-entrar a la pantalla).
final shopInitProvider = FutureProvider.autoDispose<void>((ref) async {
  final notifier = ref.read(shopProvider.notifier);
  await Future.wait([
    notifier.getAdvertisements(),
    notifier.getCoinShopItems(),
    notifier.getLiveShopItems(),
  ]);
});

class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier(this.ref) : super(ShopState()) {
    _init();
  }

  final Ref ref;
  final ShopRepository repository = getIt<ShopRepository>();

  void _init() {
    ref.listen<bool>(
      internetStatusProvider.select((async) => async.value ?? false),
      (previous, hasInternet) {
        if (!hasInternet) {
          initData();
        }
      },
    );
  }

  void initData() {
    state = state.copyWith(
      advertisements: const [],
      coinShopItems: const [],
      liveShopItemsUnitUsd: const [],
      liveShopItemsUnitCoin: const [],
    );
  }

  Future<void> getAdvertisements() async {
    final advertisements = await repository.getAdvertisements();
    state = state.copyWith(advertisements: advertisements);
  }

  Future<void> getCoinShopItems() async {
    final coinShopList = await repository.getCoinShopList();
    state = state.copyWith(coinShopItems: coinShopList);
  }

  Future<void> getLiveShopItems() async {
    final liveShopList = await repository.getLiveShopList();
    final List<LiveShopEntity> liveShopItemsUnitUsd = liveShopList
        .where((item) => item.typeId == 1)
        .toList();
    final List<LiveShopEntity> liveShopItemsUnitCoin = liveShopList
        .where((item) => item.typeId == 2)
        .toList();

    state = state.copyWith(
      liveShopItemsUnitUsd: liveShopItemsUnitUsd,
      liveShopItemsUnitCoin: liveShopItemsUnitCoin,
    );
  }

  String getItemImagePath(int id, TypeItemShop type) {
    if (type == TypeItemShop.coin) {
      return _getCoinImagePath(id);
    } else if (type == TypeItemShop.live) {
      return _getLiveImagePath(id);
    } else {
      return 'assets/images/default.png';
    }
  }

  String _getCoinImagePath(int id) {
    switch (id) {
      case 1:
        return 'assets/icons/chest-shop-first.svg';
      case 2:
        return 'assets/icons/chest-shop-second.svg';
      case 3:
        return 'assets/icons/chest-shop-third.svg';
      case > 4:
        return 'assets/icons/chest-shop-third.svg';
      default:
        return 'assets/icons/chest-shop-first.svg';
    }
  }

  String _getLiveImagePath(int id) {
    switch (id) {
      case 1 || 5:
        return 'assets/icons/heart.svg';
      case 2 || 6:
        return 'assets/icons/group-hearts-second.svg';
      case 3 || 7:
        return 'assets/icons/group-hearts-third.svg';
      case 4 || 8:
        return 'assets/icons/group-hearts-third.svg';
      default:
        return 'assets/icons/heart.svg';
    }
  }
}

enum TypeItemShop { coin, live }

class ShopState extends Equatable {
  final List<AdvertisementEntity> advertisements;
  final List<CoinShopEntity> coinShopItems;
  final List<LiveShopEntity> liveShopItemsUnitUsd;
  final List<LiveShopEntity> liveShopItemsUnitCoin;

  const ShopState({
    this.advertisements = const [],
    this.coinShopItems = const [],
    this.liveShopItemsUnitUsd = const [],
    this.liveShopItemsUnitCoin = const [],
  });

  ShopState copyWith({
    List<AdvertisementEntity>? advertisements,
    List<CoinShopEntity>? coinShopItems,
    List<LiveShopEntity>? liveShopItemsUnitUsd,
    List<LiveShopEntity>? liveShopItemsUnitCoin,
  }) {
    return ShopState(
      advertisements: advertisements ?? this.advertisements,
      coinShopItems: coinShopItems ?? this.coinShopItems,
      liveShopItemsUnitUsd: liveShopItemsUnitUsd ?? this.liveShopItemsUnitUsd,
      liveShopItemsUnitCoin:
          liveShopItemsUnitCoin ?? this.liveShopItemsUnitCoin,
    );
  }

  @override
  List<Object?> get props => [
    advertisements,
    coinShopItems,
    liveShopItemsUnitUsd,
    liveShopItemsUnitCoin,
  ];
}
