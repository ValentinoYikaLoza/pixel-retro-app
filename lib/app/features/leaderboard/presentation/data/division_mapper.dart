import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_current_division_response_model.dart';

class DivisionMapper {
  static GetCurrentDivisionResponseModel fromSocketData(
    Map<String, dynamic> data,
  ) {
    final divisions = data['division'] ?? {};

    return GetCurrentDivisionResponseModel(
      currentDivision: DivisionEntity(
        id: divisions['id'] ?? 0,
        name: divisions['name'] ?? '',
      ),
    );
  }
}
