import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/time_entity.dart';
import 'package:pixel_retro_app/app/features/mission/data/dtos/get_time_left_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/mission/domain/models/get_time_left_list_response_model.dart';

class GetTimeLeftListResponseMapper {
  static GetTimeLeftListResponseModel fromDtoToModel(
    GetTimeLeftListResponseDto response,
  ) {
    return GetTimeLeftListResponseModel(
      timeLeftUntilNextMonth: TimeEntity(
        time: response.data.timeLeftUntilNextMonth.time,
        unit: response.data.timeLeftUntilNextMonth.unit,
      ),
      timeLeftUntilNextWeek: TimeEntity(
        time: response.data.timeLeftUntilNextWeek.time,
        unit: response.data.timeLeftUntilNextWeek.unit,
      ),
      timeLeftUntilNextDay: TimeEntity(
        time: response.data.timeLeftUntilNextDay.time,
        unit: response.data.timeLeftUntilNextDay.unit,
      ),
    );
  }
}
