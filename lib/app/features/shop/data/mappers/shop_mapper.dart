import 'package:pixel_retro_app/app/features/shop/data/dtos/get_advertisement_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/shop/data/dtos/get_coin_shop_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/shop/data/dtos/get_live_shop_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/coin_shop_entity.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/live_shop_entity.dart';

class ShopMapper {
  static List<AdvertisementEntity> advertisementsFromDto(
    GetAdvertisementListResponseDto dto,
  ) {
    return dto.data
        .map(
          (a) => AdvertisementEntity(
            id: a.id,
            reward: a.reward,
            rewardType: a.rewardType,
            isClaimed: a.isClaimed,
          ),
        )
        .toList();
  }

  static List<CoinShopEntity> coinShopFromDto(GetCoinShopListResponseDto dto) {
    return dto.data
        .map(
          (c) => CoinShopEntity(id: c.id, quantity: c.quantity, price: c.price),
        )
        .toList();
  }

  static List<LiveShopEntity> liveShopFromDto(GetLiveShopListResponseDto dto) {
    return dto.data
        .map(
          (l) => LiveShopEntity(
            id: l.id,
            quantity: l.quantity,
            price: l.price,
            typeId: l.typeId,
          ),
        )
        .toList();
  }
}
