import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/shared/widgets/custom_title.dart';

final GlobalKey<_LoaderContentState> _loaderKey =
    GlobalKey<_LoaderContentState>();

class Loader {
  static show([String message = 'Cargando']) {
    if (_loaderKey.currentState != null) {
      _loaderKey.currentState!.show(message);
    }
  }

  static dissmiss() {
    if (_loaderKey.currentState != null) {
      _loaderKey.currentState!.dismiss();
    }
  }
}

class LoaderProvider extends StatelessWidget {
  const LoaderProvider({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _LoaderContent(key: _loaderKey, child: child);
  }
}

class _LoaderContent extends StatefulWidget {
  const _LoaderContent({super.key, this.child});

  final Widget? child;

  @override
  State<_LoaderContent> createState() => _LoaderContentState();
}

class _LoaderContentState extends State<_LoaderContent>
    with SingleTickerProviderStateMixin {
  bool showLoader = false;
  String message = 'Cargando';
  late AnimationController _controller;
  late Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _dotsAnimation = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  show([String message = 'Loading']) {
    setState(() {
      showLoader = true;
      this.message = message;
    });
  }

  dismiss() {
    setState(() {
      showLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (showLoader)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.lightBlue.shade100,
                ], // Light pastel gradient
              ),
            ),
          ),
        if (showLoader)
          Center(
            child: AnimatedBuilder(
              animation: _dotsAnimation,
              builder: (context, child) {
                String animatedMessage =
                    message + '.' * (_dotsAnimation.value + 1);
                return CustomTitle(title: animatedMessage, fontSize: 30);
              },
            ),
          ),
      ],
    );
  }
}
