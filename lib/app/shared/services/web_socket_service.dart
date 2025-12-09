import 'dart:async';
import 'dart:convert';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  final String userId;

  final _statsController = StreamController<Map<String, dynamic>>.broadcast();
  final _missionsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _usersController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get statsStream => _statsController.stream;
  Stream<Map<String, dynamic>> get missionsStream => _missionsController.stream;
  Stream<Map<String, dynamic>> get usersStream => _usersController.stream;

  bool _isConnected = false;
  Timer? _reconnectTimer;

  WebSocketService({required this.url, required this.userId});

  void connect() {
    try {
      // print('🔌 Conectando a WebSocket: $url $userId');
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;

      // Envía las suscripciones al conectarse
      _subscribeToChannels();

      // Escucha los mensajes del socket
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: true,
      );

      // SnackbarService.show('Conectado al servidor en tiempo real');
    } catch (e) {
      _handleError(e);
    }
  }

  void _subscribeToChannels() {
    try {
      _channel!.sink.add(
        jsonEncode({
          "event": "pusher:subscribe",
          "data": {"channel": "user.stats.$userId"},
        }),
      );

      _channel!.sink.add(
        jsonEncode({
          "event": "pusher:subscribe",
          "data": {"channel": "user.missions.$userId"},
        }),
      );

      _channel!.sink.add(
        jsonEncode({
          'event': 'pusher:subscribe',
          'data': {'channel': 'user.users.$userId'},
        }),
      );
    } catch (e) {
      SnackbarService.show(
        'Error suscribiéndose a canales',
        type: SnackbarType.error,
      );
    }
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message);
      final event = data['event'];
      final payload = data['data'];

      if (event == 'StatsUpdated') {
        final parsed = jsonDecode(payload);
        // print('📊 [WebSocket] Estadísticas recibidas: $parsed');
        _statsController.add(parsed);
      } else if (event == 'MissionsUpdated') {
        final parsed = jsonDecode(payload);
        // print('🎯 [WebSocket] Misiones recibidas: $parsed');
        _missionsController.add(parsed);
      } else if (event == 'UsersUpdated') {
        final parsed = jsonDecode(payload);
        // print('🎯 [WebSocket] Usuarios recibidos: $parsed');
        _usersController.add(parsed);
      } else if (event == 'pusher:error') {
        final error = payload is String ? jsonDecode(payload) : payload;
        SnackbarService.show(
          'Error del servidor: ${error['message'] ?? 'desconocido'}',
          type: SnackbarType.error,
        );
      } else {
        // print('⚠️ [WebSocket] Evento no reconocido: $event');
      }
    } on FormatException catch (e) {
      SnackbarService.show(
        'Error decodificando datos del socket: $e',
        type: SnackbarType.error,
      );
    } on ServiceException catch (e) {
      SnackbarService.show(e.message, type: SnackbarType.error);
    } catch (e) {
      SnackbarService.show(
        'Error inesperado en el socket: $e',
        type: SnackbarType.error,
      );
    }
  }

  void _handleError(Object error) {
    // print('❌ Error en el WebSocket: $error');
    _isConnected = false;

    // SnackbarService.show(
    //   'Error en conexión WebSocket: $error',
    //   type: SnackbarType.error,
    // );
    _attemptReconnect();
  }

  void _handleDone() {
    // print('⚠️ Conexión WebSocket cerrada.');
    _isConnected = false;

    // SnackbarService.show(
    //   'Conexión cerrada con el servidor',
    //   type: SnackbarType.info,
    // );
    _attemptReconnect();
  }

  void _attemptReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    // print('🔁 Intentando reconectar en 5 segundos...');
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  void dispose() {
    // print('🔚 Cerrando conexión WebSocket...');
    _isConnected = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _statsController.close();
    _missionsController.close();
    _usersController.close();
  }
}
