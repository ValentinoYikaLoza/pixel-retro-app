import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetService {
  InternetService._();
  static final InternetService instance = InternetService._();

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _controller.stream;

  Future<void> initialize() async {
    final connectivity = Connectivity();

    // Estado inicial
    final initialCheck = await connectivity.checkConnectivity();
    final hasConnection =
        initialCheck.isNotEmpty &&
        !initialCheck.contains(ConnectivityResult.none);
    _controller.add(hasConnection);

    // Escucha en tiempo real
    connectivity.onConnectivityChanged.listen((result) {
      final hasConnection =
          result.isNotEmpty && !result.contains(ConnectivityResult.none);
      _controller.add(hasConnection);
    });
  }
}
