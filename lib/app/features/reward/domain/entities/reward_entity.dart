class RewardEntity {
  final String id;
  final String description;
  final int currentPoints;
  final int totalPoints;
  final bool isClaimed;
  final int categoryId;
  final int typeId;

  RewardEntity({
    required this.id,
    required this.description,
    required this.currentPoints,
    required this.totalPoints,
    required this.isClaimed,
    required this.categoryId,
    required this.typeId,
  });
}
