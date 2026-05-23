import 'package:pixel_retro_app/app/features/time/data/dtos/get_time_response_dto.dart';

class GetTimeResponseMapper {
  static DateTime fromDtoToEntity(GetTimeResponseDto dto) {
    return dto.data.time;
  }
}
