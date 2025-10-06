import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_time_left_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/time_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_time_left_response_model.dart';

class GetTimeLeftResponseMapper {
  static GetTimeLeftResponseModel fromDtoToModel(GetTimeLeftResponseDto dto) {
    return GetTimeLeftResponseModel(
      timeLeft: TimeEntity(time: dto.data.time, unit: dto.data.unit),
    );
  }
}
