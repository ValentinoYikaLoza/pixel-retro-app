import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/services/dialog_service.dart';

/// Muestra la celebración animada de "+1 día de racha". Se auto-cierra sola.
void showStreakCelebration(int streak) {
  DialogService.show(
    _StreakCelebration(streak: streak),
    barrierDismissible: true,
  );
}

/// Celebración tipo Duolingo: el fuego entra con un rebote y late suavemente,
/// el número aparece con escala/desvanecido y el diálogo se cierra solo.
class _StreakCelebration extends StatefulWidget {
  final int streak;

  const _StreakCelebration({required this.streak});

  @override
  State<_StreakCelebration> createState() => _StreakCelebrationState();
}

class _StreakCelebrationState extends State<_StreakCelebration>
    with TickerProviderStateMixin {
  late final AnimationController _entry; // entrada (escala/opacidad)
  late final AnimationController _pulse; // latido continuo del fuego

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Se cierra sola tras la celebración.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) DialogService.close();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _entry, curve: Curves.elasticOut);
    final fade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.purple, AppColors.backgroundDark],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.orange, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fuego con latido suave.
                ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.12).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/fire.svg',
                    height: 96,
                    width: 96,
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Text(
                      '${widget.streak}',
                      style: TextStyle(
                        fontSize: 56,
                        height: 1,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pixel',
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 5
                          ..color = AppColors.red,
                      ),
                    ),
                    Text(
                      '${widget.streak}',
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontSize: 56,
                        height: 1,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pixel',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.streak == 1
                      ? '¡Empezó tu racha!'
                      : '¡Racha de ${widget.streak} días!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vuelve mañana para no perderla',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
