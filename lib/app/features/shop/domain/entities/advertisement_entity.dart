class AdvertisementEntity {
  final int id;
  final String description;
  final double reward;
  final int typeId;
  final bool isClaimed;

  AdvertisementEntity({
    required this.id,
    required this.description,
    required this.reward,
    required this.typeId,
    required this.isClaimed,
  });
}
