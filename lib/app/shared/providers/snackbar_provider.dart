import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/breakpoints.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/functions/generate_random_string.dart';
import 'package:pixel_retro_app/app/shared/models/snackbar_model.dart';
import 'package:pixel_retro_app/app/shared/widgets/snackbar.dart';

final GlobalKey<SnackbarContentState> snackbarKey =
    GlobalKey<SnackbarContentState>();

class SnackbarProvider extends StatelessWidget {
  const SnackbarProvider({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _SnackbarContent(key: snackbarKey, child: child);
  }
}

class _SnackbarContent extends StatefulWidget {
  const _SnackbarContent({super.key, this.child});

  final Widget? child;

  @override
  State<_SnackbarContent> createState() => SnackbarContentState();
}

class SnackbarContentState extends State<_SnackbarContent> {
  List<SnackbarModel> snackbars = [];

  SnackbarModel addSnackbar(String message, SnackbarType type) {
    final SnackbarModel newSnackbar = SnackbarModel(
      id: generateRandomString(10),
      message: message,
      type: type,
    );

    setState(() {
      snackbars.add(newSnackbar);
    });

    Future.delayed(const Duration(seconds: 4), () {
      removeSnackbar(newSnackbar);
    });

    return newSnackbar;
  }

  removeSnackbar(SnackbarModel? snackbar) {
    if (snackbar == null) return;
    setState(() {
      snackbars.remove(snackbar);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          if (widget.child != null) widget.child!,
          Positioned(
            top: Breakpoints.isMdUp(context) ? 73 : screen.padding.top + 12,
            right: Breakpoints.isMdUp(context) ? 62 : 16,
            left: Breakpoints.isMdUp(context) ? null : 16,
            child: Wrap(
              direction: Axis.vertical,
              runAlignment: Breakpoints.isMdUp(context)
                  ? WrapAlignment.end
                  : WrapAlignment.center,
              crossAxisAlignment: Breakpoints.isMdUp(context)
                  ? WrapCrossAlignment.end
                  : WrapCrossAlignment.center,
              spacing: 16,
              children: snackbars.reversed.toList().map((snackbar) {
                return Snackbar(
                  message: snackbar.message,
                  onClose: () {
                    removeSnackbar(snackbar);
                  },
                  type: snackbar.type,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
