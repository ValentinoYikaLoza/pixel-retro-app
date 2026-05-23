import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

/// Indicador de carga para el estado `loading` de un `AsyncValue.when`.
class ScreenLoader extends StatelessWidget {
  const ScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.orange),
    );
  }
}

/// Vista de error para el estado `error` de un `AsyncValue.when`.
class ScreenError extends StatelessWidget {
  const ScreenError({super.key, this.message = 'Ocurrió un error'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
