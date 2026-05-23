import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/services/dialog_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_text_button.dart';

/// Diálogo genérico de la app (confirmación o aviso), reutilizable en cualquier
/// parte del juego. Panel oscuro con borde/acento neón, ícono opcional y uno o
/// dos botones (si [cancelText] es null se muestra un solo botón = modo aviso).
///
/// Uso rápido:
/// ```dart
/// ConfirmDialog.show(
///   title: 'SALIR',
///   message: '¿Seguro?',
///   icon: Icons.logout_rounded,
///   cancelText: 'SEGUIR',
///   onConfirm: () { ... },
/// );
/// ```
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.accentColor = AppColors.neonPurple,
    this.confirmText = 'ACEPTAR',
    this.cancelText,
    this.confirmColor,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final IconData? icon;

  /// Color del ícono, el contorno del título y el borde del panel.
  final Color accentColor;

  final String confirmText;

  /// Si es null, se muestra un único botón (modo aviso).
  final String? cancelText;

  /// Color del botón de confirmar (por defecto, [accentColor]).
  final Color? confirmColor;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  /// Muestra el diálogo con el navigator raíz (sin `BuildContext`).
  static Future<void> show({
    required String title,
    required String message,
    IconData? icon,
    Color accentColor = AppColors.neonPurple,
    String confirmText = 'ACEPTAR',
    String? cancelText,
    Color? confirmColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return DialogService.show(
      barrierDismissible: barrierDismissible,
      ConfirmDialog(
        title: title,
        message: message,
        icon: icon,
        accentColor: accentColor,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmFill = confirmColor ?? accentColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.purple, AppColors.backgroundDark],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.4),
              blurRadius: 24,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Icon(icon, color: accentColor, size: 30),
              ),
              const SizedBox(height: 14),
            ],
            _StrokedTitle(title, accentColor),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: AppColors.white.withValues(alpha: 0.85),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cancelText != null) ...[
                  CustomTextButton(
                    width: 130,
                    height: 44,
                    radius: 12,
                    label: cancelText!,
                    baseColor: AppColors.backgroundDark,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                CustomTextButton(
                  width: cancelText != null ? 130 : 180,
                  height: 44,
                  radius: 12,
                  label: confirmText,
                  baseColor: confirmFill,
                  flashColor: confirmFill,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StrokedTitle extends StatelessWidget {
  const _StrokedTitle(this.text, this.strokeColor);

  final String text;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pixel',
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pixel',
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}

/// Confirma salir de una partida en curso, avisando lo que se pierde. Si ya se
/// perdió (`isLost`) sale directo. Mientras se decide pausa el juego (y lo
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

  ConfirmDialog.show(
    barrierDismissible: false,
    title: 'SALIR',
    message:
        'Si sales, perderás esta partida y la vida que usaste. El progreso de '
        'esta partida no se guarda.',
    icon: Icons.logout_rounded,
    accentColor: AppColors.orange,
    confirmText: 'SALIR',
    cancelText: 'SEGUIR',
    confirmColor: AppColors.red,
    onConfirm: onLeave,
    onCancel: () {
      if (forcedPause) togglePause(); // reanuda si lo habíamos pausado
    },
  );
}
