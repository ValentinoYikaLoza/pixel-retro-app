class MissionEntity {
  final int id;
  final String description;
  final int currentPoints;
  final int totalPoints;
  final RewardState isClaimed;
  final RewardCategory category;

  MissionEntity({
    required this.id,
    required this.description,
    required this.currentPoints,
    required this.totalPoints,
    required this.isClaimed,
    required this.category,
  });
}

enum RewardCategory { bronzeChest, silverChest, goldChest }

enum RewardState { unclaimed, claimed }
