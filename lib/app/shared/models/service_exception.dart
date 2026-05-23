/// Error tipado de la capa de datos.
///
/// La capa de datos traduce cualquier error de red a esta excepción y la
/// presentación la captura para mostrar un mensaje y cerrar el loader.
class ServiceException implements Exception {
  final String message;
  final int? statusCode;

  ServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'ServiceException($statusCode): $message';
}
