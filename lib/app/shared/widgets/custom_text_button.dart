import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

class CustomTextButton extends StatefulWidget {
  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.radius,
    required this.width,
    required this.height,
    required this.label,
    this.flashColor = AppColors.neonPurple,
    this.baseColor = AppColors.purple,
  });

  final VoidCallback onPressed;
  final double radius;
  final double width;
  final double height;
  final String label;
  final Color flashColor;
  final Color baseColor;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: widget.baseColor,
      end: widget.flashColor,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse().then((_) {
      widget.onPressed();
    });
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(widget.radius),
                boxShadow: [
                  if (!_isPressed)
                    BoxShadow(
                      color: widget.flashColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  // Efecto de luz interna para el flash
                  if (_isPressed)
                    BoxShadow(
                      color: widget.flashColor.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                ],
                border: Border.all(
                  color: widget.flashColor,
                  width: _isPressed ? 3 : 2,
                ),
                // Efecto de gradiente para mejorar el aspecto de flash
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _colorAnimation.value!.withOpacity(0.9),
                    _colorAnimation.value!,
                    _colorAnimation.value!.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Center(
                child: Stack(
                  children: [
                    // Texto con borde
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = widget.flashColor,
                      ),
                    ),
                    // Texto de relleno
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.baseColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
