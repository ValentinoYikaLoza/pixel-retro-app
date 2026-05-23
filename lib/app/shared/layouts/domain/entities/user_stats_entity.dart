import 'package:equatable/equatable.dart';

/// Estadísticas del usuario (monedas, vidas, racha, división).
///
/// Los campos son opcionales: si la fuente (HTTP o WebSocket) no envía un
/// campo, queda en `null` y el estado conserva su valor actual.
class UserStatsEntity extends Equatable {
  final int? userId;
  final int? coins;
  final int? lives;
  final int? streak;
  final int? divisionId;

  const UserStatsEntity({
    this.userId,
    this.coins,
    this.lives,
    this.streak,
    this.divisionId,
  });

  @override
  List<Object?> get props => [userId, coins, lives, streak, divisionId];
}
