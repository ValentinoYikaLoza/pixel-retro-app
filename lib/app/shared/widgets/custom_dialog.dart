import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class CustomDialog extends StatefulWidget {
  final String title;
  final String content;
  final String buttonAcceptText;
  final String buttonCancelText;
  final VoidCallback? onAcceptPressed;
  final VoidCallback? onCancelPressed;
  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.buttonAcceptText,
    required this.buttonCancelText,
    this.onAcceptPressed,
    this.onCancelPressed,
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 14, left: 23, right: 9),
      backgroundColor: AppColors.orange,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.backgroundDark,
          fontFamily: 'Inter',
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        widget.content,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          fontFamily: 'Inter',
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        const SizedBox(height: 20),
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            Get.back();

            if (widget.onAcceptPressed != null) {
              widget.onAcceptPressed!();
            }
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
                widget.buttonAcceptText,
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
