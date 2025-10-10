import 'package:pixel_retro_app/app/shared/providers/time_provider.dart';

class GetTimeListResponseModel {
  final TimeEntity timeLeftUntilNextDay;
  final TimeEntity timeLeftUntilNextWeek;
  final TimeEntity timeLeftUntilNextMonth;
  final String currentMonth;

  GetTimeListResponseModel({
    required this.timeLeftUntilNextDay,
    required this.timeLeftUntilNextWeek,
    required this.timeLeftUntilNextMonth,
    required this.currentMonth,
  });
}
