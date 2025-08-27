import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

final GlobalKey<_LoaderContentState> _loaderKey =
    GlobalKey<_LoaderContentState>();

class Loader {
  static show() {
    if (_loaderKey.currentState != null) {
      _loaderKey.currentState!.show();
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

  show() {
    setState(() {
      showLoader = true;
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
              color: AppColors.backgroundDark.withOpacity(0.8),
            ),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
          ),
      ],
    );
  }
}
