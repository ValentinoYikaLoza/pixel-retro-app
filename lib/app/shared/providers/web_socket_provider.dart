import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/environment.dart';
import 'package:pixel_retro_app/app/shared/services/session_service.dart';
import 'package:pixel_retro_app/app/shared/services/web_socket_service.dart';
import 'package:pixel_retro_app/di.dart';

// Proveedor del servicio principal de WebSocket
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final socket = WebSocketService(
    url: Environment.urlBaseSocket,
    userId: getIt<SessionService>().userId,
  );

  socket.connect();
  ref.onDispose(socket.dispose);
  return socket;
});
