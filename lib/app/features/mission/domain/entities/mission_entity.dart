import 'package:equatable/equatable.dart';

class MissionEntity extends Equatable {
  final int id;
  final String description;
  final int currentPoints;
  final int totalPoints;
  final RewardState isClaimed;
  final RewardCategory category;

  const MissionEntity({
    required this.id,
    required this.description,
    required this.currentPoints,
    required this.totalPoints,
    required this.isClaimed,
    required this.category,
  });

  @override
  List<Object?> get props => [
    id,
    description,
    currentPoints,
    totalPoints,
    isClaimed,
    category,
  ];
}

enum RewardCategory { bronzeChest, silverChest, goldChest }

enum RewardState { unclaimed, claimed }
