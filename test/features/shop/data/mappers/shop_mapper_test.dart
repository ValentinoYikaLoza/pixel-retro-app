import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/shop/data/dtos/get_advertisement_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/shop/data/mappers/shop_mapper.dart';
import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';

void main() {
  group('ShopMapper.advertisementsFromDto', () {
    test('maps reward + rewardType (estructurado, sin prosa)', () {
      final dto = GetAdvertisementListResponseDto.fromJson({
        'success': true,
        'message': 'ok',
        'data': [
          {'id': 1, 'reward': 10, 'rewardType': 'coin', 'is_claimed': false},
          {'id': 2, 'reward': 5, 'rewardType': 'life', 'is_claimed': true},
        ],
      });

      final ads = ShopMapper.advertisementsFromDto(dto);

      expect(ads, hasLength(2));
      expect(ads.first.reward, 10);
      expect(ads.first.rewardType, AdRewardType.coin);
      expect(ads[1].rewardType, AdRewardType.life);
      expect(ads[1].isClaimed, isTrue);
    });

    test('rewardType cae a coin si es desconocido/ausente', () {
      final dto = GetAdvertisementListResponseDto.fromJson({
        'data': [
          {'id': 1, 'reward': 0},
        ],
      });

      expect(
        ShopMapper.advertisementsFromDto(dto).first.rewardType,
        AdRewardType.coin,
      );
    });
  });
}
