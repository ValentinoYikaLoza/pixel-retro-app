import 'package:pixel_retro_app/app/features/shop/domain/datasources/shop_datasource.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/coin_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/live_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopDatasource datasource;

  ShopRepositoryImpl(this.datasource);

  /// Catálogos casi estáticos: se cachean en memoria por sesión.
  List<AdvertisementEntity>? _advertisementsCache;
  List<CoinShopEntity>? _coinShopCache;
  List<LiveShopEntity>? _liveShopCache;

  @override
  Future<List<AdvertisementEntity>> getAdvertisements() async {
    final cached = _advertisementsCache;
    if (cached != null) return cached;

    final ads = await datasource.getAdvertisements();
    _advertisementsCache = ads;
    return ads;
  }

  @override
  Future<List<CoinShopEntity>> getCoinShopList() async {
    final cached = _coinShopCache;
    if (cached != null) return cached;

    final items = await datasource.getCoinShopList();
    _coinShopCache = items;
    return items;
  }

  @override
  Future<List<LiveShopEntity>> getLiveShopList() async {
    final cached = _liveShopCache;
    if (cached != null) return cached;

    final items = await datasource.getLiveShopList();
    _liveShopCache = items;
    return items;
  }

  @override
  Future<void> purchaseAdvertisement(int advertisementId) async {
    await datasource.purchaseAdvertisement(advertisementId);
    // Reclamar un anuncio cambia su estado: invalida su caché.
    _advertisementsCache = null;
  }

  @override
  Future<void> purchaseCoinShopItem(int itemId) {
    return datasource.purchaseCoinShopItem(itemId);
  }

  @override
  Future<void> purchaseLiveShopItem(int itemId) {
    return datasource.purchaseLiveShopItem(itemId);
  }

  @override
  void clearCache() {
    _advertisementsCache = null;
    _coinShopCache = null;
    _liveShopCache = null;
  }
}
