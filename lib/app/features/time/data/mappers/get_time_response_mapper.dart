import 'package:pixel_retro_app/app/features/time/data/dtos/get_time_response_dto.dart';
import 'package:pixel_retro_app/app/features/time/domain/models/get_time_response_model.dart';

class GetTimeResponseMapper {
  static GetTimeResponseModel fromDtoToModel(GetTimeResponseDto dto) {
    return GetTimeResponseModel(currentDate: dto.data.time);
  }
}
