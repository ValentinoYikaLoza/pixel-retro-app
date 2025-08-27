import 'package:pixel_retro_app/app/features/shop/domain/datasources/shop_datasource.dart';
import 'package:pixel_retro_app/app/features/shop/domain/models/get_advertisement_list_response_model.dart';
import 'package:pixel_retro_app/app/features/shop/domain/models/get_coin_shop_list_response_model.dart';
import 'package:pixel_retro_app/app/features/shop/domain/models/get_live_shop_list_response_model.dart';
import 'package:pixel_retro_app/app/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopDatasource datasource;

  ShopRepositoryImpl(this.datasource);

  @override
  Future<GetAdvertisementListResponseModel> getAdvertisements() {
    return datasource.getAdvertisements();
  }

  @override
  Future<GetCoinShopListResponseModel> getCoinShopList() {
    return datasource.getCoinShopList();
  }

  @override
  Future<GetLiveShopListResponseModel> getLiveShopList() {
    return datasource.getLiveShopList();
  }

  @override
  Future<void> purchaseAdvertisement(int advertisementId) {
    return datasource.purchaseAdvertisement(advertisementId);
  }

  @override
  Future<void> purchaseCoinShopItem(int itemId) {
    return datasource.purchaseCoinShopItem(itemId);
  }

  @override
  Future<void> purchaseLiveShopItem(int itemId) {
    return datasource.purchaseLiveShopItem(itemId);
  }
}
