import 'package:dio/dio.dart';

class ErrorService {
  static String verificarErrorBase(
    String errorMessage,
    Object e, {
    bool mensajeServicio = false,
  }) {
    if (e is DioException) {
      try {
        if (mensajeServicio) {
          // Si toma el mensaje de error del servicio
          if (e.response?.data['message'] != null &&
              e.response?.data['message'] != '') {
            errorMessage = e.response?.data['message'];
          }

          if (e.response?.data['mensaje'] != null &&
              e.response?.data['mensaje'] != '') {
            errorMessage = e.response?.data['mensaje'];
          }

          if (e.response?.data['msg'] != null &&
              e.response?.data['msg'] != '') {
            errorMessage = e.response?.data['msg'];
          }
        }
      } catch (_) {}
    }

    return errorMessage;
  }
}
