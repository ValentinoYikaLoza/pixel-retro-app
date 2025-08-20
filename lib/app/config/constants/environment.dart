import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load();
  }

  static String urlBase = dotenv.get('URL_BASE');
}
