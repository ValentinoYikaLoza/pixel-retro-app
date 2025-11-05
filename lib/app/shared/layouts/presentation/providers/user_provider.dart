import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/repositories/user_repository.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/providers/web_socket_provider.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this.ref) : super(UserState());

  final Ref ref;
  final UserRepository repository = getIt<UserRepository>();

  StreamSubscription<Map<String, dynamic>>? _statsSub;

  /// Inicializa el usuario y se suscribe a los streams del WebSocket
  Future<void> initData() async {
    // Obtiene la instancia del socket desde Riverpod
    final socket = ref.read(websocketServiceProvider);
    // 📊 Escucha las estadísticas en tiempo real
    _statsSub = socket.statsStream.listen((stats) {
      state = state.copyWith(
        userId: stats['user']['id'] ?? state.userId,
        coins: stats['user']['coins'] ?? state.coins,
        lives: stats['user']['lives'] ?? state.lives,
        streak: stats['user']['streak'] ?? state.streak,
        divisionId: stats['user']['division_id'] ?? state.divisionId,
      );
    });
  }

  Future<void> getUser() async {
    try {
      await initData();
      await repository.getUser();
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo los datos del usuario',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> updateCoins(int coins) async {
    try {
      await repository.updateCoins(coins);
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error actualizando monedas del usuario',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> updateLives(int lives) async {
    try {
      await repository.updateLives(lives);
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error actualizando vidas del usuario',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> updateStreak() async {
    try {
      await repository.updateStreak();
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error actualizando racha del usuario',
        type: SnackbarType.error,
      );
    }
  }

  @override
  void dispose() {
    _statsSub?.cancel();
    super.dispose();
  }
}

class UserState {
  final int coins;
  final int lives;
  final int streak;
  final int userId;
  final int divisionId;

  UserState({
    this.coins = 0,
    this.lives = 0,
    this.streak = 0,
    this.userId = 0,
    this.divisionId = 0,
  });

  UserState copyWith({
    int? coins,
    int? lives,
    int? streak,
    int? userId,
    int? divisionId,
  }) {
    return UserState(
      coins: coins ?? this.coins,
      lives: lives ?? this.lives,
      streak: streak ?? this.streak,
      userId: userId ?? this.userId,
      divisionId: divisionId ?? this.divisionId,
    );
  }
}
