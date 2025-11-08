import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/shared/providers/snackbar_provider.dart';
import 'package:pixel_retro_app/app/shared/widgets/connection_detector.dart';
import 'package:pixel_retro_app/app/shared/widgets/loader.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key, required this.child});
  final Widget child;

  @override
  AppState createState() => AppState();
}

class AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    Loader.init(ref);
  }

  @override
  Widget build(BuildContext context) {
    return SnackbarProvider(
      child: LoaderOverlay(child: ConnectionDetector(child: widget.child)),
    );
  }
}
