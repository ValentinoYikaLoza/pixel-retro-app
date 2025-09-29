import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/widgets/tabs_layout.dart';
import 'package:pixel_retro_app/app/shared/widgets/loader.dart';

class LayoutView extends ConsumerStatefulWidget {
  const LayoutView({super.key, required this.child});

  final Widget child;

  @override
  LayoutViewState createState() => LayoutViewState();
}

class LayoutViewState extends ConsumerState<LayoutView> {
  @override
  void initState() {
    super.initState();
    Loader.init(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const TabsLayout(),
      body: LoaderOverlay(child: widget.child),
    );
  }
}
