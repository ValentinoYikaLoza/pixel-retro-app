import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';

class NoInternetDialog extends StatefulWidget {
  const NoInternetDialog({super.key});

  @override
  State<NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<NoInternetDialog> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 14, left: 23, right: 9),
      backgroundColor: AppColors.orange,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Sin conexión',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.backgroundDark,
          fontFamily: 'Inter',
        ),
      ),
      content: const Text(
        'Por favor, conéctate a internet para continuar.',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
      ),
      actions: [
        const SizedBox(height: 20),
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            Get.back();

            Get.currentRoute == AppRoutes.root
                ? AppRoutes.go(AppRoutes.home)
                : () {};
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 48,
            decoration: BoxDecoration(
              color: _pressed
                  ? AppColors.white.withOpacity(0.5)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Entendido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _pressed ? AppColors.white : AppColors.orange,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
