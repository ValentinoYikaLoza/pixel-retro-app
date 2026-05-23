import 'package:pixel_retro_app/app/features/leaderboard/data/dtos/get_division_list_response_dto.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';

class GetDivisionListResponseMapper {
  static List<DivisionEntity> fromDtoToEntities(
    GetDivisionListResponseDto dto,
  ) {
    return dto.data.map((e) => DivisionEntity(id: e.id, name: e.name)).toList();
  }
}
