import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_division_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';

class GetDivisionListResponseMapper {
  static GetDivisionListResponseModel fromDtoToModel(
    GetDivisionListResponseDto dto,
  ) {
    return GetDivisionListResponseModel(
      divisions: dto.data.map((e) {
        return DivisionEntity(id: e.id, name: e.name);
      }).toList(),
    );
  }
}
