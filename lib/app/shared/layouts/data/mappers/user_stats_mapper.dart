import 'package:pixel_retro_app/app/shared/layouts/data/dtos/get_user_response_dto.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/entities/user_stats_entity.dart';

class UserStatsMapper {
  /// HTTP: respuesta de `POST /getUser` ya parseada en DTO.
  static UserStatsEntity fromDto(GetUserResponseDto dto) {
    return UserStatsEntity(
      userId: dto.data.id,
      coins: dto.data.coins,
      lives: dto.data.lives,
      streak: dto.data.streak,
      divisionId: dto.data.divisionId,
    );
  }

  /// WebSocket: payload en vivo (`{ user: { id, coins, lives, streak,
  /// division_id } }`).
  static UserStatsEntity fromSocketData(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>? ?? const {};
    return UserStatsEntity(
      userId: user['id'] as int?,
      coins: user['coins'] as int?,
      lives: user['lives'] as int?,
      streak: user['streak'] as int?,
      divisionId: user['division_id'] as int?,
    );
  }
}
