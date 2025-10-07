class UpdateProgressRequestModel {
  final String userId;
  final String rewardId;
  final int currentPoints;

  UpdateProgressRequestModel({
    required this.userId,
    required this.rewardId,
    required this.currentPoints,
  });
}
