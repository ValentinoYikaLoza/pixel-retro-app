import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/services/dialog_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';

/// Diálogo de confirmación genérico con la estética de la app.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'SALIR',
    this.cancelText = 'SEGUIR',
    this.confirmColor = AppColors.red,
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.purple,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.neonPurple, width: 2),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.white.withValues(alpha: 0.85),
          fontFamily: 'Inter',
          height: 1.3,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      actions: [
        CustomTextButton(
          width: 120,
          height: 44,
          radius: 12,
          label: cancelText,
          baseColor: AppColors.backgroundDark,
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
        ),
        const SizedBox(width: 10),
        CustomTextButton(
          width: 120,
          height: 44,
          radius: 12,
          label: confirmText,
          baseColor: confirmColor,
          flashColor: confirmColor,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }
}

/// Confirma salir de una partida en curso, avisando lo que se pierde. Si ya se
/// perdió (`isLost`) sale directo. Mientras se decide, pausa el juego (y lo
/// reanuda si se cancela) para que no avance por detrás del diálogo.
void confirmGameExit({
  required bool isLost,
  required bool isPaused,
  required VoidCallback onLeave,
  required VoidCallback togglePause,
}) {
  if (isLost) {
    onLeave();
    return;
  }

  final forcedPause = !isPaused;
  if (forcedPause) togglePause();

  DialogService.show(
    barrierDismissible: false,
    ConfirmDialog(
      title: 'Salir de la partida',
      message:
          'Si sales, perderás esta partida y la vida que usaste. El progreso '
          'de esta partida no se guarda.',
      confirmText: 'SALIR',
      cancelText: 'SEGUIR',
      onConfirm: onLeave,
      onCancel: () {
        if (forcedPause) togglePause(); // reanuda si lo habíamos pausado
      },
    ),
  );
}
