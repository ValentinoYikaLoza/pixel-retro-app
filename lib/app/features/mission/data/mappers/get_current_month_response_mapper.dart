import 'package:pixel_retro_app/app/features/mission/data/dtos/get_current_month_response_dto.dart';

class GetCurrentMonthResponseMapper {
  static String fromDtoToModel(GetCurrentMonthResponseDto response) {
    final monthMap = {
      1: 'ENERO',
      2: 'FEBRERO',
      3: 'MARZO',
      4: 'ABRIL',
      5: 'MAYO',
      6: 'JUNIO',
      7: 'JULIO',
      8: 'AGOSTO',
      9: 'SEPTIEMBRE',
      10: 'OCTUBRE',
      11: 'NOVIEMBRE',
      12: 'DICIEMBRE',
    };
    return monthMap[response.data]!;
  }
}
