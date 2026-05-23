import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/config/routes/app_routes.dart';
import 'package:pixel_retro_app/app/features/shop/presentation/providers/shop_provider.dart';

/// Tarjeta de anuncio recompensado ("mira un video y gana monedas/vidas").
///
/// Sigue el patrón de las apps profesionales:
/// - Icono de la recompensa con fondo tintado.
/// - Texto claro de la recompensa + indicación de que es un video corto.
/// - Botón de acción ("VER") con estilo de llamada a la acción.
/// - Feedback táctil al presionar, consistente con [ShopItem].
class AnuncioContainerWidget extends StatefulWidget {
  const AnuncioContainerWidget({
    super.key,
    required this.reward,
    required this.imagePath,
    required this.color,
    required this.type,
  });

  final int reward;
  final String imagePath;
  final Color color;
  final TypeItemShop type;

  @override
  State<AnuncioContainerWidget> createState() => _AnuncioContainerWidgetState();
}

class _AnuncioContainerWidgetState extends State<AnuncioContainerWidget> {
  bool _pressed = false;

  void _onTap() {
    switch (widget.type) {
      case TypeItemShop.coin:
        AppRoutes.go(AppRoutes.adRewardedCoins);
        break;
      case TypeItemShop.live:
        AppRoutes.go(AppRoutes.adRewardedLives);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rewardLabel = widget.type == TypeItemShop.coin ? 'monedas' : 'vidas';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.white.withValues(alpha: 0.08)
              : AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.orange, width: 2),
          boxShadow: [
            if (_pressed)
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.55),
                blurRadius: 22,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icono de la recompensa con fondo tintado
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  widget.imagePath,
                  height: 36,
                  width: 36,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Texto de la recompensa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gana ${widget.reward} $rewardLabel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.smart_display_rounded,
                        size: 16,
                        color: AppColors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Mira un video corto',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Botón de acción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.emerald,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'VER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
