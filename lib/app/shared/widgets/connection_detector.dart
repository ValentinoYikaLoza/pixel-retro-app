import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';

class ConnectionDetector extends ConsumerStatefulWidget {
  final Widget child;
  const ConnectionDetector({super.key, required this.child});

  @override
  ConnectionDetectorState createState() => ConnectionDetectorState();
}

class ConnectionDetectorState extends ConsumerState<ConnectionDetector> {
  bool _dialogShown = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      internetStatusProvider.select((async) => async.value ?? true),
      (previous, hasInternet) {
        if (!hasInternet && !_dialogShown) {
          _dialogShown = true;
          _showNoInternetDialog();
        } else if (hasInternet && _dialogShown) {
          _dialogShown = false;
          if (Get.isDialogOpen == true) Get.back();
        }
      },
    );

    return widget.child;
  }

  void _showNoInternetDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          contentPadding: const EdgeInsets.only(top: 14, left: 23, right: 9),
          backgroundColor: AppColors.orange,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

            // ---------- AQUI USAMOS StatefulBuilder ----------
            StatefulBuilder(
              builder: (context, setLocalState) {
                return GestureDetector(
                  onTapDown: (_) => setLocalState(() => _pressed = true),
                  onTapUp: (_) {
                    setLocalState(() => _pressed = false);
                    Get.back();
                  },
                  onTapCancel: () => setLocalState(() => _pressed = false),
                  child: Container(
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
                    child: const Center(
                      child: Text(
                        'Entendido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
