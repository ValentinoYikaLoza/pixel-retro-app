import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/coin_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/live_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/repositories/shop_repository.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
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

  /// Compra en curso, para evitar doble toque.
  bool _buying = false;

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
      liveShopItems: const [],
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
    // Las vidas se compran solo con monedas; ya no hay variante en dinero.
    final liveShopList = await repository.getLiveShopList();
    state = state.copyWith(liveShopItems: liveShopList);
  }

  /// Compra un paquete de vidas con monedas. El backend valida el saldo y
  /// acredita; refrescamos al usuario para reflejar monedas/vidas al instante.
  Future<void> buyLives(int id) async {
    if (_buying) return;
    _buying = true;
    try {
      await repository.purchaseLiveShopItem(id);
      await ref.read(userProvider.notifier).getUser();
      SnackbarService.show('¡Vidas agregadas!', type: SnackbarType.success);
    } on ServiceException catch (e) {
      SnackbarService.show(e.message, type: SnackbarType.error);
    } finally {
      _buying = false;
    }
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
      case 1:
        return 'assets/icons/heart.svg';
      case 2:
        return 'assets/icons/group-hearts-second.svg';
      case 3:
        return 'assets/icons/group-hearts-third.svg';
      case >= 4:
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
  final List<LiveShopEntity> liveShopItems;

  const ShopState({
    this.advertisements = const [],
    this.coinShopItems = const [],
    this.liveShopItems = const [],
  });

  ShopState copyWith({
    List<AdvertisementEntity>? advertisements,
    List<CoinShopEntity>? coinShopItems,
    List<LiveShopEntity>? liveShopItems,
  }) {
    return ShopState(
      advertisements: advertisements ?? this.advertisements,
      coinShopItems: coinShopItems ?? this.coinShopItems,
      liveShopItems: liveShopItems ?? this.liveShopItems,
    );
  }

  @override
  List<Object?> get props => [advertisements, coinShopItems, liveShopItems];
}
