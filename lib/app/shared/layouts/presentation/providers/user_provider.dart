import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this.ref) : super(UserState());

  final Ref ref;

  void initData() {
    state = state.copyWith(coins: 100, lives: 5, streak: 1);
  }
}

class UserState {
  final int coins;
  final int lives;
  final int streak;

  UserState({this.coins = 0, this.lives = 0, this.streak = 0});

  UserState copyWith({int? coins, int? lives, int? streak}) {
    return UserState(
      coins: coins ?? this.coins,
      lives: lives ?? this.lives,
      streak: streak ?? this.streak,
    );
  }
}
