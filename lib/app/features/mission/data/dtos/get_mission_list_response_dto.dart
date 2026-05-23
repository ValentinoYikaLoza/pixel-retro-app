/// Respuesta de `POST /listMissions`.
///
/// Forma: `{ success, message, data: { dailyMissions, weeklyMissions,
/// monthlyMissions } }`. El parseo es defensivo: si falta un campo se usa un
/// valor por defecto en lugar de lanzar.
class GetMissionListResponseDto {
  final bool success;
  final String message;
  final MissionListData data;

  GetMissionListResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetMissionListResponseDto.fromJson(Map<String, dynamic> json) {
    return GetMissionListResponseDto(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: MissionListData.fromJson(
        json['data'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class MissionListData {
  final List<MissionDto> dailyMissions;
  final List<MissionDto> weeklyMissions;
  final List<MissionDto> monthlyMissions;

  MissionListData({
    required this.dailyMissions,
    required this.weeklyMissions,
    required this.monthlyMissions,
  });

  factory MissionListData.fromJson(Map<String, dynamic> json) {
    return MissionListData(
      dailyMissions: _parseList(json['dailyMissions']),
      weeklyMissions: _parseList(json['weeklyMissions']),
      monthlyMissions: _parseList(json['monthlyMissions']),
    );
  }

  static List<MissionDto> _parseList(dynamic value) {
    return (value as List<dynamic>? ?? [])
        .map((e) => MissionDto.fromJson(e as Map<String, dynamic>? ?? const {}))
        .toList();
  }
}

class MissionDto {
  final int id;
  final int currentValue;
  final String description;
  final int totalValue;
  final int rewardId;
  final int statusId;

  MissionDto({
    required this.id,
    required this.currentValue,
    required this.description,
    required this.totalValue,
    required this.rewardId,
    required this.statusId,
  });

  factory MissionDto.fromJson(Map<String, dynamic> json) {
    return MissionDto(
      id: json['id'] as int? ?? 0,
      currentValue: json['current_value'] as int? ?? 0,
      description: json['description']?.toString() ?? '',
      totalValue: json['total_value'] as int? ?? 0,
      rewardId: json['reward_id'] as int? ?? 0,
      statusId: json['status_id'] as int? ?? 0,
    );
  }
}
