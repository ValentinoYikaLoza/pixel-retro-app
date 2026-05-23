import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso centralizado y validado a las variables de entorno (`.env`).
///
/// Cada getter lanza si la variable falta o está vacía, de modo que un
/// `.env` mal configurado falla rápido y con un mensaje claro en vez de
/// propagar cadenas vacías por toda la app.
class Environment {
  const Environment._();

  static Future<void> initEnvironment() async {
    await dotenv.load();
  }

  static String get urlBase => _require('URL_BASE');
  static String get urlBaseSocket => _require('URL_BASE_SOCKET');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError(
        'Falta la variable de entorno "$key" en el archivo .env',
      );
    }
    return value;
  }
}
