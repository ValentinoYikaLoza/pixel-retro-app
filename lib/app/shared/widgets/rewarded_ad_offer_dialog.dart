import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

/// Pantalla de introducción / consentimiento para anuncios recompensados
/// (rewarded y rewarded interstitial).
///
/// La política de AdMob exige mostrar, ANTES del anuncio, un mensaje claro de
/// la recompensa y una opción visible para no verlo. Este diálogo cumple eso
/// con dos botones: "Ver anuncio" y "Ahora no".
class RewardedAdOfferDialog extends StatelessWidget {
  const RewardedAdOfferDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onAccept,
    this.acceptText = 'Ver anuncio',
    this.cancelText = 'Ahora no',
  });

  final String title;
  final String message;
  final VoidCallback onAccept;
  final String acceptText;
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.orange,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.backgroundDark,
          fontFamily: 'Inter',
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: _DialogButton(
                text: cancelText,
                filled: false,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DialogButton(
                text: acceptText,
                filled: true,
                icon: Icons.play_arrow_rounded,
                onTap: () {
                  Navigator.of(context).pop();
                  onAccept();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DialogButton extends StatefulWidget {
  const _DialogButton({
    required this.text,
    required this.filled,
    required this.onTap,
    this.icon,
  });

  final String text;
  final bool filled;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.filled ? AppColors.orange : AppColors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: widget.filled
              ? (_pressed
                    ? AppColors.white.withValues(alpha: 0.7)
                    : AppColors.white)
              : AppColors.white.withValues(alpha: _pressed ? 0.25 : 0.12),
          borderRadius: BorderRadius.circular(15),
          border: widget.filled
              ? null
              : Border.all(color: AppColors.white, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fg, size: 20),
              const SizedBox(width: 2),
            ],
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
