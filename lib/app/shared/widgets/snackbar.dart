import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';

class Snackbar extends StatelessWidget {
  const Snackbar({
    super.key,
    required this.message,
    required this.onClose,
    required this.type,
  });

  final String message;
  final VoidCallback onClose;
  final SnackbarType type;

  @override
  Widget build(BuildContext context) {
    // Acento por tipo, dentro de la paleta de la app.
    late Color accent;
    late String iconPath;

    switch (type) {
      case SnackbarType.error:
        accent = AppColors.red;
        iconPath = 'assets/icons/error.svg';
        break;
      case SnackbarType.success:
        accent = AppColors.emerald;
        iconPath = 'assets/icons/check.svg';
        break;
      case SnackbarType.info:
        accent = AppColors.neonPurple;
        iconPath = 'assets/icons/info.svg';
        break;
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: 280,
        maxWidth: MediaQuery.of(context).size.width - 32,
      ),
      decoration: BoxDecoration(
        // Panel oscuro con leve tinte púrpura, como los marcos del juego.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple, AppColors.backgroundDark],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono con marco acentuado.
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent, width: 1.5),
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 22,
                width: 22,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),

            // Mensaje.
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: AppColors.white,
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),

            // Botón de cierre.
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/close.svg',
                    height: 18,
                    width: 18,
                    colorFilter: ColorFilter.mode(
                      AppColors.white.withValues(alpha: 0.8),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
