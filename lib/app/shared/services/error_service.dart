import 'package:dio/dio.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';

/// Traduce errores crudos (de Dio u otros) a un [ServiceException] tipado.
///
/// La capa de datos siempre debe lanzar [ServiceException]; la presentación
/// solo conoce este tipo de error.
class ErrorService {
  const ErrorService._();

  /// Claves usuales que el backend usa para el mensaje de error.
  static const _messageKeys = ['message', 'mensaje', 'msg'];

  static ServiceException toServiceException(
    Object error, {
    String fallback = 'Ocurrió un error inesperado',
  }) {
    if (error is ServiceException) return error;

    if (error is DioException) {
      final data = error.response?.data;
      String? message;
      if (data is Map) {
        for (final key in _messageKeys) {
          final value = data[key];
          if (value is String && value.trim().isNotEmpty) {
            message = value;
            break;
          }
        }
      }
      return ServiceException(
        message ?? fallback,
        statusCode: error.response?.statusCode,
      );
    }

    return ServiceException(fallback);
  }
}
