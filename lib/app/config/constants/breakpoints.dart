import 'package:flutter/material.dart';

class Breakpoints {
  static const double sm = 600;
  static const double md = 960;
  static const double lg = 1280;
  static const double xl = 1920;

  // Verifica si la pantalla es pequeña o más (smUp)
  static bool isSmUp(BuildContext context) {
    return MediaQuery.of(context).size.width >= sm;
  }

  // Verifica si la pantalla es pequeña o menos (smDown)
  static bool isSmDown(BuildContext context) {
    return MediaQuery.of(context).size.width < sm;
  }

  // Verifica si la pantalla es mediana o más (mdUp)
  static bool isMdUp(BuildContext context) {
    return MediaQuery.of(context).size.width >= md;
  }

  // Verifica si la pantalla es mediana o menos (mdDown)
  static bool isMdDown(BuildContext context) {
    return MediaQuery.of(context).size.width < md;
  }

  // Verifica si la pantalla es grande o más (lgUp)
  static bool isLgUp(BuildContext context) {
    return MediaQuery.of(context).size.width >= lg;
  }

  // Verifica si la pantalla es grande o menos (lgDown)
  static bool isLgDown(BuildContext context) {
    return MediaQuery.of(context).size.width < lg;
  }

  // Verifica si la pantalla es extra grande o más (xlUp)
  static bool isXlUp(BuildContext context) {
    return MediaQuery.of(context).size.width >= xl;
  }

  // Verifica si la pantalla es extra grande o menos (xlDown)
  static bool isXlDown(BuildContext context) {
    return MediaQuery.of(context).size.width < xl;
  }
}
