/// Tipo de misión: define en qué tabla la busca el backend (daily/weekly/monthly).
enum MissionType { daily, weekly, monthly }

/// Datos para avanzar el progreso de una misión concreta del usuario.
/// (`userId` lo añade el datasource desde la sesión.)
class UpdateProgressRequestModel {
  final MissionType missionType;

  /// Id de la fila usuario-misión (`MissionEntity.id`).
  final int missionId;

  /// Cantidad de progreso a sumar (delta).
  final int progress;

  UpdateProgressRequestModel({
    required this.missionType,
    required this.missionId,
    required this.progress,
  });
}
