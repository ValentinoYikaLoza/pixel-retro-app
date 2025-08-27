import 'package:pixel_retro_app/app/features/shop/domain/datasources/shop_datasource.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/coin_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/live_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/models/get_advertisement_list_response_model.dart';
import 'package:pixel_retro_app/app/features/shop/domain/models/get_coin_shop_list_response_model.dart';
import 'package:pixel_retro_app/app/features/shop/domain/models/get_live_shop_list_response_model.dart';

class ShopDatasourceImpl implements ShopDatasource {
  @override
  Future<GetAdvertisementListResponseModel> getAdvertisements() {
    return Future.delayed(Duration(seconds: 2), () {
      return GetAdvertisementListResponseModel(
        advertisementList: [
          AdvertisementEntity(
            id: 1,
            description: 'Ver anuncio para obtener 10 monedas',
            reward: 10,
            typeId: 1,
            isClaimed: false,
          ),
          AdvertisementEntity(
            id: 2,
            description: 'Ver anuncio para obtener 5 vidas adicionales',
            reward: 5,
            typeId: 2,
            isClaimed: false,
          ),
        ],
      );
    });
  }

  @override
  Future<GetCoinShopListResponseModel> getCoinShopList() {
    return Future.delayed(Duration(seconds: 2), () {
      return GetCoinShopListResponseModel(
        coinShopList: [
          CoinShopEntity(id: 1, quantity: 100, price: 1.99),
          CoinShopEntity(id: 2, quantity: 300, price: 4.99),
          CoinShopEntity(id: 3, quantity: 300, price: 9.99),
          CoinShopEntity(id: 4, quantity: 1400, price: 19.99),
        ],
      );
    });
  }

  @override
  Future<GetLiveShopListResponseModel> getLiveShopList() {
    return Future.delayed(Duration(seconds: 2), () {
      return GetLiveShopListResponseModel(
        liveShopList: [
          LiveShopEntity(id: 1, quantity: 5, price: 1.99, typeId: 1),
          LiveShopEntity(id: 2, quantity: 15, price: 4.99, typeId: 1),
          LiveShopEntity(id: 3, quantity: 30, price: 8.99, typeId: 1),
          LiveShopEntity(id: 4, quantity: 50, price: 14.99, typeId: 1),
          LiveShopEntity(id: 5, quantity: 5, price: 120, typeId: 2),
          LiveShopEntity(id: 6, quantity: 15, price: 300, typeId: 2),
          LiveShopEntity(id: 7, quantity: 30, price: 540, typeId: 2),
          LiveShopEntity(id: 8, quantity: 50, price: 900, typeId: 2),
        ],
      );
    });
  }

  @override
  Future<void> purchaseAdvertisement(int advertisementId) {
    return Future.delayed(Duration(seconds: 2), () {
      // Simula la compra exitosa del anuncio
      return;
    });
  }

  @override
  Future<void> purchaseCoinShopItem(int itemId) {
    return Future.delayed(Duration(seconds: 2), () {
      // Simula la compra exitosa del item de la tienda de monedas
      return;
    });
  }

  @override
  Future<void> purchaseLiveShopItem(int itemId) {
    return Future.delayed(Duration(seconds: 2), () {
      // Simula la compra exitosa del item de la tienda de vidas
      return;
    });
  }
}
