import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/config/constants/environment.dart';
import 'package:pixel_retro_app/app/shared/services/web_socket_service.dart';

// Proveedor del servicio principal de WebSocket
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final socket = WebSocketService(url: Environment.urlBaseSocket, userId: 1);

  socket.connect();
  ref.onDispose(socket.dispose);
  return socket;
});
