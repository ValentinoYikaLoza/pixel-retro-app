import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/services/dialog_service.dart';
import 'package:pixel_retro_app/app/shared/widgets/no_internet_dialog.dart';

class ConnectionDetector extends ConsumerStatefulWidget {
  final Widget child;
  const ConnectionDetector({super.key, required this.child});

  @override
  ConnectionDetectorState createState() => ConnectionDetectorState();
}

class ConnectionDetectorState extends ConsumerState<ConnectionDetector> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      internetStatusProvider.select((async) => async.value ?? true),
      (previous, hasInternet) {
        if (!hasInternet && !_dialogShown) {
          _dialogShown = true;
          _showNoInternetDialog();
        } else if (hasInternet && _dialogShown) {
          _dialogShown = false;
          DialogService.close();
        }
      },
    );

    return widget.child;
  }

  void _showNoInternetDialog() {
    DialogService.show(const NoInternetDialog(), barrierDismissible: false);
  }
}
