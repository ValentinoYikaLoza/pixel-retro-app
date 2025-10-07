import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/time_entity.dart';

class GetTimeLeftListResponseModel {
  final TimeEntity timeLeftUntilNextMonth;
  final TimeEntity timeLeftUntilNextWeek;
  final TimeEntity timeLeftUntilNextDay;

  GetTimeLeftListResponseModel({
    required this.timeLeftUntilNextMonth,
    required this.timeLeftUntilNextWeek,
    required this.timeLeftUntilNextDay,
  });
}
