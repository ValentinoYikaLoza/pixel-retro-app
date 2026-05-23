import 'package:equatable/equatable.dart';
import 'package:pixel_retro_app/app/features/mission/domain/entities/mission_entity.dart';

/// Conjunto de misiones que se muestran a la vez: diarias, semanal y mensual.
class MissionsBoardEntity extends Equatable {
  final MissionEntity monthlyReward;
  final MissionEntity weeklyReward;
  final List<MissionEntity> dailyRewards;

  const MissionsBoardEntity({
    required this.monthlyReward,
    required this.weeklyReward,
    required this.dailyRewards,
  });

  @override
  List<Object?> get props => [monthlyReward, weeklyReward, dailyRewards];
}
