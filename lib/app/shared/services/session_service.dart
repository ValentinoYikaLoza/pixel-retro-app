/// Mantiene los datos de la sesión del usuario actual.
///
/// Se registra como singleton en `di.dart` y se inyecta donde se necesite el
/// `userId`, evitando una variable global mutable y que la capa de datos
/// dependa de `main.dart`.
class SessionService {
  SessionService({required this.userId});

  final String userId;
}
