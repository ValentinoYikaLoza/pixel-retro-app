import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/routes/app_router.dart';

/// Diálogos globales sin `BuildContext`, usando el navigator raíz de go_router.
///
/// Reemplaza a `Get.dialog` / `Get.back` / `Get.isDialogOpen`.
class DialogService {
  const DialogService._();

  static bool isOpen = false;

  static Future<void> show(
    Widget dialog, {
    bool barrierDismissible = true,
  }) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null || isOpen) return;

    isOpen = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (_) => dialog,
      );
    } finally {
      isOpen = false;
    }
  }

  static void close() {
    if (!isOpen) return;
    rootNavigatorKey.currentState?.pop();
    isOpen = false;
  }
}
