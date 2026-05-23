import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    // Theme colors based on type
    late Color backgroundColor;
    late Color textColor;
    late Color borderColor;
    late String iconPath;

    switch (type) {
      case SnackbarType.error:
        backgroundColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        borderColor = const Color(0xFFF5C6CB);
        iconPath = 'assets/icons/error.svg';
        break;
      case SnackbarType.success:
        backgroundColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF155724);
        borderColor = const Color(0xFFC3E6CB);
        iconPath = 'assets/icons/check.svg';
        break;
      case SnackbarType.info:
        backgroundColor = const Color(0xFFD1ECF1);
        textColor = const Color(0xFF0C5460);
        borderColor = const Color(0xFFBEE5EB);
        iconPath = 'assets/icons/info.svg';
        break;
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: 320,
        maxWidth: MediaQuery.of(context).size.width - 32,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with puzzle piece style
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),

            // Message
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),

            // Close button with puzzle piece style
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/close.svg',
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
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
