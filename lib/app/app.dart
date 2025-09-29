import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/shared/providers/snackbar_provider.dart';

class App extends StatelessWidget {
  const App({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return SnackbarProvider(child: child);
  }
}
