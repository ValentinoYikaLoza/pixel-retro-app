import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

/// Botón de "Modo infinito" para los selectores de nivel. Navega al juego con
/// nivel 0 (centinela de infinito en el backend).
class InfiniteModeButton extends StatelessWidget {
  const InfiniteModeButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.emerald, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '∞',
              style: TextStyle(
                color: AppColors.emerald,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'INFINITO',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pixel',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
