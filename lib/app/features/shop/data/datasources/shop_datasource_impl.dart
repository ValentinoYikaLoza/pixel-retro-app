import 'package:pixel_retro_app/app/config/api/api.dart';
import 'package:pixel_retro_app/app/config/constants/api_endpoints.dart';
import 'package:pixel_retro_app/app/features/shop/data/dtos/get_advertisement_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/shop/data/dtos/get_coin_shop_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/shop/data/dtos/get_live_shop_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/shop/data/mappers/shop_mapper.dart';
import 'package:pixel_retro_app/app/features/shop/domain/datasources/shop_datasource.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/coin_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/live_shop_entity.dart';
import 'package:pixel_retro_app/app/shared/services/error_service.dart';
import 'package:pixel_retro_app/app/shared/services/session_service.dart';

class ShopDatasourceImpl implements ShopDatasource {
  ShopDatasourceImpl(this._api, this._session);

  final Api _api;
  final SessionService _session;

  @override
  Future<List<AdvertisementEntity>> getAdvertisements() async {
    try {
      final formData = {'user_id': _session.userId};
      final response = await _api.post(
        ApiEndpoints.listAdvertisements,
        data: formData,
      );
      final dto = GetAdvertisementListResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return ShopMapper.advertisementsFromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al cargar los anuncios',
      );
    }
  }

  @override
  Future<List<CoinShopEntity>> getCoinShopList() async {
    try {
      final response = await _api.get(ApiEndpoints.listCoinShop);
      final dto = GetCoinShopListResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return ShopMapper.coinShopFromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al cargar la tienda de monedas',
      );
    }
  }

  @override
  Future<List<LiveShopEntity>> getLiveShopList() async {
    try {
      final response = await _api.get(ApiEndpoints.listLiveShop);
      final dto = GetLiveShopListResponseDto.fromJson(
        response.data as Map<String, dynamic>? ?? const {},
      );
      return ShopMapper.liveShopFromDto(dto);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al cargar la tienda de vidas',
      );
    }
  }

  @override
  Future<void> purchaseAdvertisement(int advertisementId) async {
    try {
      final formData = {
        'user_id': _session.userId,
        'advertisement_id': '$advertisementId',
      };
      await _api.post(ApiEndpoints.purchaseAdvertisement, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al reclamar el anuncio',
      );
    }
  }

  @override
  Future<void> purchaseCoinShopItem(int itemId) async {
    try {
      final formData = {'user_id': _session.userId, 'item_id': '$itemId'};
      await _api.post(ApiEndpoints.purchaseCoinShopItem, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al comprar el paquete de monedas',
      );
    }
  }

  @override
  Future<void> purchaseLiveShopItem(int itemId) async {
    try {
      final formData = {'user_id': _session.userId, 'item_id': '$itemId'};
      await _api.post(ApiEndpoints.purchaseLiveShopItem, data: formData);
    } catch (e) {
      throw ErrorService.toServiceException(
        e,
        fallback: 'Error al comprar el paquete de vidas',
      );
    }
  }
}
