import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/coin_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/live_shop_entity.dart';

abstract class ShopRepository {
  Future<List<AdvertisementEntity>> getAdvertisements();
  Future<List<CoinShopEntity>> getCoinShopList();
  Future<List<LiveShopEntity>> getLiveShopList();
  Future<void> purchaseCoinShopItem(int itemId);
  Future<void> purchaseLiveShopItem(int itemId);
  Future<void> purchaseAdvertisement(int advertisementId);

  /// Limpia la caché en memoria (forzar recarga desde red).
  void clearCache();
}
