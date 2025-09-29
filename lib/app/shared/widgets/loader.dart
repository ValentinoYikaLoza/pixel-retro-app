import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';

final loaderProvider = StateProvider<bool>((ref) => false);

class Loader {
  static late WidgetRef _ref;

  static void init(WidgetRef ref) {
    _ref = ref;
  }

  static void show() {
    _ref.read(loaderProvider.notifier).state = true;
  }

  static void dissmiss() {
    _ref.read(loaderProvider.notifier).state = false;
  }
}

class LoaderOverlay extends ConsumerWidget {
  const LoaderOverlay({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loaderProvider);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundDark.withOpacity(0.8),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
          ),
      ],
    );
  }
}
