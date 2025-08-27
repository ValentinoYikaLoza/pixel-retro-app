import 'package:pixel_retro_app/app/features/shop/domain/models/get_advertisement_list_response_model.dart';
import 'package:pixel_retro_app/app/features/shop/domain/models/get_coin_shop_list_response_model.dart';
import 'package:pixel_retro_app/app/features/shop/domain/models/get_live_shop_list_response_model.dart';

abstract class ShopRepository {
  Future<GetAdvertisementListResponseModel> getAdvertisements();
  Future<GetCoinShopListResponseModel> getCoinShopList();
  Future<GetLiveShopListResponseModel> getLiveShopList();
  Future<void> purchaseCoinShopItem(int itemId);
  Future<void> purchaseLiveShopItem(int itemId);
  Future<void> purchaseAdvertisement(int advertisementId);
}
