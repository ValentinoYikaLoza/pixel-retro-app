import 'package:pixel_retro_app/app/features/mission/data/dtos/get_mission_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/missions_board_entity.dart';

class MissionMapper {
  static const _rewardCategoryMap = {
    1: RewardCategory.bronzeChest,
    2: RewardCategory.silverChest,
    3: RewardCategory.goldChest,
  };

  static const _rewardStateMap = {
    1: RewardState.unclaimed,
    2: RewardState.unclaimed,
    3: RewardState.claimed,
    4: RewardState.claimed,
  };

  /// HTTP: respuesta de `GET/POST /listMissions` ya parseada en DTO.
  static MissionsBoardEntity fromDto(GetMissionListResponseDto dto) {
    final daily = dto.data.dailyMissions.map(_fromDtoItem).toList();
    final weekly = dto.data.weeklyMissions.map(_fromDtoItem).toList();
    final monthly = dto.data.monthlyMissions.map(_fromDtoItem).toList();

    return MissionsBoardEntity(
      dailyRewards: daily,
      weeklyReward: weekly.isNotEmpty ? weekly.first : _emptyMission(),
      monthlyReward: monthly.isNotEmpty ? monthly.first : _emptyMission(),
    );
  }

  /// WebSocket: payload en vivo (`{ missions: { dailyMissions, ... } }`).
  static MissionsBoardEntity fromSocketData(Map<String, dynamic> data) {
    final missions = data['missions'] ?? {};

    final daily = (missions['dailyMissions'] as List<dynamic>? ?? [])
        .map((m) => _fromMap(m))
        .toList();
    final weekly = (missions['weeklyMissions'] as List<dynamic>? ?? [])
        .map((m) => _fromMap(m))
        .toList();
    final monthly = (missions['monthlyMissions'] as List<dynamic>? ?? [])
        .map((m) => _fromMap(m))
        .toList();

    return MissionsBoardEntity(
      dailyRewards: daily,
      weeklyReward: weekly.isNotEmpty ? weekly.first : _emptyMission(),
      monthlyReward: monthly.isNotEmpty ? monthly.first : _emptyMission(),
    );
  }

  static MissionEntity _fromDtoItem(MissionDto m) => _build(
    id: m.id,
    description: m.description,
    rewardId: m.rewardId,
    statusId: m.statusId,
    currentPoints: m.currentValue,
    totalPoints: m.totalValue,
  );

  static MissionEntity _fromMap(Map<String, dynamic> m) => _build(
    id: m['id'] ?? 0,
    description: m['description'] ?? '',
    rewardId: m['reward_id'] ?? 0,
    statusId: m['status_id'] ?? 0,
    currentPoints: m['current_value'] ?? 0,
    totalPoints: m['total_value'] ?? 0,
  );

  static MissionEntity _build({
    required int id,
    required String description,
    required int rewardId,
    required int statusId,
    required int currentPoints,
    required int totalPoints,
  }) {
    return MissionEntity(
      id: id,
      description: description,
      category: _rewardCategoryMap[rewardId] ?? RewardCategory.bronzeChest,
      isClaimed: _rewardStateMap[statusId] ?? RewardState.unclaimed,
      currentPoints: currentPoints,
      totalPoints: totalPoints,
    );
  }

  static MissionEntity _emptyMission() {
    return MissionEntity(
      id: 0,
      description: 'Sin datos',
      category: RewardCategory.bronzeChest,
      isClaimed: RewardState.unclaimed,
      currentPoints: 0,
      totalPoints: 0,
    );
  }
}
