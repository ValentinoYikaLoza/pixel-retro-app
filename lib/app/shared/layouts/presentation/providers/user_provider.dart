import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/streak/presentation/widgets/streak_celebration.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/data/mappers/user_stats_mapper.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/repositories/user_repository.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/providers/web_socket_provider.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

/// Dispara la carga del usuario (datos del appbar). Se mantiene vivo durante
/// toda la sesión: se carga una vez y el WebSocket lo mantiene al día.
final userInitProvider = FutureProvider<void>((ref) async {
  await ref.read(userProvider.notifier).getUser();
});

class UserNotifier extends StateNotifier<UserState>
    with WidgetsBindingObserver {
  UserNotifier(this.ref) : super(UserState()) {
    // Re-hace el check-in diario al volver del background (cruce de medianoche).
    WidgetsBinding.instance.addObserver(this);
  }

  final Ref ref;
  final UserRepository repository = getIt<UserRepository>();

  StreamSubscription<Map<String, dynamic>>? _statsSub;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getUser();
    }
  }

  /// Inicializa el usuario y se suscribe a los streams del WebSocket
  Future<void> initData() async {
    // Obtiene la instancia del socket desde Riverpod
    final socket = ref.read(websocketServiceProvider);
    // Evita suscripciones duplicadas si se recarga la pantalla.
    await _statsSub?.cancel();
    // 📊 Escucha las estadísticas en tiempo real
    _statsSub = socket.statsStream.listen((stats) {
      final model = UserStatsMapper.fromSocketData(stats);
      state = state.copyWith(
        userId: model.userId,
        coins: model.coins,
        lives: model.lives,
        streak: model.streak,
        divisionId: model.divisionId,
      );
    });
  }

  /// Carga inicial vía HTTP + suscripción a actualizaciones en vivo.
  /// Lanza [ServiceException] si falla; la UI lo maneja vía AsyncValue.
  Future<void> getUser() async {
    await initData();
    final stats = await repository.getUser();
    state = state.copyWith(
      userId: stats.userId,
      coins: stats.coins,
      lives: stats.lives,
      streak: stats.streak,
      divisionId: stats.divisionId,
    );

    // El backend hace el check-in diario al cargar el usuario; si la racha
    // subió hoy, celebramos con la animación.
    if (stats.streakIncremented && (stats.streak ?? 0) > 0) {
      showStreakCelebration(stats.streak!);
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

  Future<void> updateExp(int exp) async {
    try {
      await repository.updateExp(exp);
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error actualizando la experiencia del usuario',
        type: SnackbarType.error,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statsSub?.cancel();
    super.dispose();
  }
}

class UserState extends Equatable {
  final int coins;
  final int lives;
  final int streak;
  final int userId;
  final int divisionId;

  const UserState({
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

  @override
  List<Object?> get props => [coins, lives, streak, userId, divisionId];
}
