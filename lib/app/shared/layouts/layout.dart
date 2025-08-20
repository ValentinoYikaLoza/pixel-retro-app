import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/shared/widgets/tabs_layout.dart';

class Layout extends StatefulWidget {
  const Layout({super.key, required this.child});

  final Widget child;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: const TabsLayout(),
    );
  }
}
