import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/shared/services/orientation_service.dart';

/// Intro de marca al entrar a un juego. También hace el cambio a landscape;
/// el fade de la ruta enmascara la rotación del sistema.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.arguments = const {}});

  final Map<String, dynamic> arguments;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String title = '';
  String imagePath = '';

  @override
  void initState() {
    super.initState();

    final gameMode = widget.arguments['gameMode']?.toString() ?? '';
    title = 'Bienvenido a $gameMode Game';
    imagePath = 'assets/images/$gameMode.png';

    _enterGameOrientation();

    // Intro de marca; luego pasa al selector de nivel del juego.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      AppRoutes.go(gameMode.isEmpty ? AppRoutes.home : '/level-$gameMode-game');
    });
  }

  /// Cambia a landscape esperando a que el sistema aplique la orientación.
  Future<void> _enterGameOrientation() async {
    await OrientationService.setLandscape();
    await OrientationService.setImmersiveMode();
    OrientationService.setOverlayColor(AppColors.neonPurple);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            border: Border.all(color: AppColors.neonPurple, width: 5),
          ),
          child: Column(
            spacing: 20,
            children: [
              Stack(
                children: [
                  Text(
                    title.isNotEmpty
                        ? '${title[0].toUpperCase()}${title.substring(1)}'
                        : '',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pixel',
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = AppColors.neonPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Fill
                  Text(
                    title.isNotEmpty
                        ? '${title[0].toUpperCase()}${title.substring(1)}'
                        : '',
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pixel',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonPurple, width: 2),
                ),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
