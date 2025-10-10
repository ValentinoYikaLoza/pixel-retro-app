import 'package:pixel_retro_app/app/shared/models/get_time_list_response_model.dart';
import 'package:pixel_retro_app/app/shared/providers/time_provider.dart';

class TimeMapper {
  static final Map<String, String> monthMap = {
    '1': 'ENERO',
    '2': 'FEBRERO',
    '3': 'MARZO',
    '4': 'ABRIL',
    '5': 'MAYO',
    '6': 'JUNIO',
    '7': 'JULIO',
    '8': 'AGOSTO',
    '9': 'SEPTIEMBRE',
    '10': 'OCTUBRE',
    '11': 'NOVIEMBRE',
    '12': 'DICIEMBRE',
  };

  static GetTimeListResponseModel fromSocketData(Map<String, dynamic> data) {
    final timeLeftUntilNextDay =
        data['timeList']['timeLeftUntilNextDay'] as Map<String, dynamic>? ?? {};
    final timeLeftUntilNextWeek =
        data['timeList']['timeLeftUntilNextWeek'] as Map<String, dynamic>? ??
        {};
    final timeLeftUntilNextMonth =
        data['timeList']['timeLeftUntilNextMonth'] as Map<String, dynamic>? ??
        {};

    final currentMonthInt = data['timeList']['currentMonth'] ?? 0;

    return GetTimeListResponseModel(
      timeLeftUntilNextDay: TimeEntity(
        time: timeLeftUntilNextDay['time'] ?? 0,
        unit: timeLeftUntilNextDay['unit'] ?? '',
      ),
      timeLeftUntilNextWeek: TimeEntity(
        time: timeLeftUntilNextWeek['time'] ?? 0,
        unit: timeLeftUntilNextWeek['unit'] ?? '',
      ),
      timeLeftUntilNextMonth: TimeEntity(
        time: timeLeftUntilNextMonth['time'] ?? 0,
        unit: timeLeftUntilNextMonth['unit'] ?? '',
      ),
      currentMonth: monthMap[currentMonthInt.toString()] ?? '',
    );
  }
}
