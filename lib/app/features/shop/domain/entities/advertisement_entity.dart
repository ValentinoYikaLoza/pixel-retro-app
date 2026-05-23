import 'package:equatable/equatable.dart';

/// Qué entrega el anuncio al verlo.
enum AdRewardType { coin, life }

class AdvertisementEntity extends Equatable {
  final int id;
  final int reward;
  final AdRewardType rewardType;
  final bool isClaimed;

  const AdvertisementEntity({
    required this.id,
    required this.reward,
    required this.rewardType,
    required this.isClaimed,
  });

  @override
  List<Object?> get props => [id, reward, rewardType, isClaimed];
}
