import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/services/dialog_service.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_dialog.dart';

class ShopItem extends StatefulWidget {
  const ShopItem({
    super.key,
    required this.imagePath,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.color,
    this.onConfirm,
  });

  final String imagePath;
  final int quantity;
  final double price;
  final ShopItemUnit unit;
  final Color color;

  /// Acción al confirmar la compra en el diálogo. Si es null, se muestra un
  /// aviso de "Próximamente" (p. ej. la compra con dinero real aún sin pasarela).
  final VoidCallback? onConfirm;

  @override
  State<ShopItem> createState() => _ShopItemState();
}

class _ShopItemState extends State<ShopItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        DialogService.show(
          CustomDialog(
            title: '¿Quieres comprar este artículo?',
            content:
                '¡No te lo pierdas! Puedes comprar este artículo en cualquier momento.',
            buttonAcceptText: 'Comprar',
            buttonCancelText: 'Cancelar',
            onAcceptPressed: () {
              final confirm = widget.onConfirm;
              if (confirm != null) {
                confirm();
              } else {
                SnackbarService.show(
                  'Próximamente...',
                  type: SnackbarType.info,
                );
              }
            },
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.white.withValues(alpha: 0.3)
              : AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.orange, width: 2),

          // SOMBRA CAMBIANTE SEGÚN PRESIÓN
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

        child: Column(
          spacing: 10,
          children: [
            SvgPicture.asset(widget.imagePath, height: 72),
            Text(
              '${widget.quantity}',
              style: const TextStyle(
                fontSize: 18,
                height: 18 / 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),

            if (widget.unit == ShopItemUnit.usd)
              Text(
                'USD \$${widget.price}',
                style: TextStyle(
                  fontSize: 18,
                  height: 18 / 16,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),

            if (widget.unit == ShopItemUnit.coin)
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/coin.svg',
                    height: 24,
                    width: 24,
                  ),
                  Text(
                    widget.price.toStringAsFixed(
                      widget.price.truncateToDouble() == widget.price ? 0 : 2,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      height: 18 / 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.yellow,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

enum ShopItemUnit { usd, coin }
