import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/models/get_user_response_model.dart';
import 'package:pixel_retro_app/app/shared/layouts/domain/repositories/user_repository.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this.ref) : super(UserState());

  final Ref ref;
  final UserRepository repository = getIt<UserRepository>();

  void initData() {
    state = state.copyWith(coins: 0, lives: 0, streak: 0, exp: 0);
  }

  Future<void> getUserData() async {
    try {
      final GetUserResponseModel response = await repository.getUser();
      state = state.copyWith(
        coins: response.user.coins,
        lives: response.user.lives,
        streak: response.user.streak,
      );
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo datos del usuario',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> updateCoins(int coins, bool add) async {
    try {
      await repository.updateCoins(coins, add);
      await getUserData();
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error actualizando monedas del usuario',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> updateLives(int lives, bool add) async {
    try {
      await repository.updateLives(lives, add);
      await getUserData();
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
      await getUserData();
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
      await getUserData();
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error actualizando experiencia del usuario',
        type: SnackbarType.error,
      );
    }
  }
}

class UserState {
  final int coins;
  final int lives;
  final int streak;

  UserState({this.coins = 0, this.lives = 0, this.streak = 0});

  UserState copyWith({int? coins, int? lives, int? streak, int? exp}) {
    return UserState(
      coins: coins ?? this.coins,
      lives: lives ?? this.lives,
      streak: streak ?? this.streak,
    );
  }
}
