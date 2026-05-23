import 'package:pixel_retro_app/app/features/shop/domain/entities/advertisement_entity.dart';

/// Respuesta de `POST /listAdvertisements`.
/// Forma: `{ success, message, data: [{ id, reward, rewardType, isClaimed }] }`.
/// `rewardType ∈ {"coin","life"}`. NO se envía texto: el front arma la frase.
class GetAdvertisementListResponseDto {
  final bool success;
  final String message;
  final List<AdvertisementDto> data;

  GetAdvertisementListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetAdvertisementListResponseDto.fromJson(Map<String, dynamic> json) {
    return GetAdvertisementListResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (e) => AdvertisementDto.fromJson(
              e as Map<String, dynamic>? ?? const {},
            ),
          )
          .toList(),
    );
  }
}

class AdvertisementDto {
  final int id;
  final int reward;
  final AdRewardType rewardType;
  final bool isClaimed;

  AdvertisementDto({
    required this.id,
    required this.reward,
    required this.rewardType,
    required this.isClaimed,
  });

  factory AdvertisementDto.fromJson(Map<String, dynamic> json) {
    return AdvertisementDto(
      id: json['id'] as int? ?? 0,
      reward: json['reward'] as int? ?? 0,
      rewardType: _rewardTypeFrom(json['rewardType']),
      isClaimed: json['is_claimed'] as bool? ?? false,
    );
  }

  static AdRewardType _rewardTypeFrom(dynamic value) {
    return value?.toString() == 'life' ? AdRewardType.life : AdRewardType.coin;
  }
}
