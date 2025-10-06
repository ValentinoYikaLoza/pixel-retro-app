import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_current_division_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_current_division_response_model.dart';

class GetCurrentDivisionResponseMapper {
  static GetCurrentDivisionResponseModel fromDtoToModel(
    GetCurrentDivisionResponseDto dto,
  ) {
    return GetCurrentDivisionResponseModel(
      currentDivision: DivisionEntity(id: dto.data.id, name: dto.data.name),
    );
  }
}
