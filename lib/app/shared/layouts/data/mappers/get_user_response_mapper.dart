import 'package:pixel_retro_app/app/shared/layouts/data/dtos/get_user_response_dto.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/entities/user_entity.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/models/get_user_response_model.dart';

class GetUserResponseMapper {
  static GetUserResponseModel fromDtoToModel(GetUserResponseDto dto) {
    return GetUserResponseModel(
      user: UserEntity(
        id: dto.data.id,
        name: dto.data.name,
        coins: dto.data.coins,
        lives: dto.data.lives,
        streak: dto.data.streak,
      ),
    );
  }
}
