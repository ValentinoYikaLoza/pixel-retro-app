import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/time_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_current_division_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_time_left_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_user_list_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
      return LeaderboardNotifier(ref);
    });

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier(this.ref) : super(LeaderboardState());

  final Ref ref;
  final LeaderboardRepository repository = getIt<LeaderboardRepository>();

  Future<void> getUsers() async {
    try {
      final GetUserListResponseModel response = await repository.getUsers();
      state = state.copyWith(users: response.users);
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo los usuarios',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> getDivisions() async {
    try {
      final GetDivisionListResponseModel response = await repository
          .getDivisions();
      state = state.copyWith(divisions: response.divisions);
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo las divisiones',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> getCurrentUser() async {
    final userId = ref.read(userProvider).userId;
    if (userId == 0) return;

    state.users.map((user) {
      if (user.id == userId) {
        state = state.copyWith(currentUser: user);
      }
    });
  }

  Future<void> getCurrentDivision() async {
    try {
      final GetCurrentDivisionResponseModel response = await repository
          .getCurrentDivision();
      state = state.copyWith(currentDivision: response.currentDivision);
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo la division actual',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> getTimeLeft() async {
    try {
      final GetTimeLeftResponseModel response = await repository.getTimeLeft();
      state = state.copyWith(timeLeft: response.timeLeft);
    } on ServiceException catch (_) {
      SnackbarService.show(
        'Error obteniendo el tiempo restante',
        type: SnackbarType.error,
      );
    }
  }

  String getDivisionImage(int index) {
    if (state.currentDivision == null) {
      return index < 3
          ? 'assets/icons/trophy-1-empty.svg'
          : 'assets/icons/trophy-2-empty.svg';
    }

    final List<String> divisionActiveImageList = [
      'assets/icons/trophies/bronze.svg',
      'assets/icons/trophies/silver.svg',
      'assets/icons/trophies/gold.svg',
      'assets/icons/trophies/sapphire.svg',
      'assets/icons/trophies/ruby.svg',
      'assets/icons/trophies/emerald.svg',
      'assets/icons/trophies/amethyst.svg',
      'assets/icons/trophy-2-empty.svg',
      'assets/icons/trophy-2-empty.svg',
      'assets/icons/trophy-2-empty.svg',
    ];

    final List<String> divisionInactiveImageList = [
      'assets/icons/trophy-1-empty.svg',
      'assets/icons/trophy-1-empty.svg',
      'assets/icons/trophy-1-empty.svg',
      'assets/icons/trophy-2-empty.svg',
      'assets/icons/trophy-2-empty.svg',
      'assets/icons/trophy-2-empty.svg',
      'assets/icons/trophy-2-empty.svg',
      'assets/icons/trophy-2-empty.svg',
      'assets/icons/trophy-2-empty.svg',
      'assets/icons/trophy-2-empty.svg',
    ];

    return index <= (state.currentDivision!.id)
        ? divisionActiveImageList[index - 1]
        : divisionInactiveImageList[index - 1];
  }
}

class LeaderboardState {
  final DivisionEntity? currentDivision;
  final List<DivisionEntity> divisions;
  final List<UserDivisionEntity> users;
  final UserDivisionEntity? currentUser;
  final TimeEntity? timeLeft;

  LeaderboardState({
    this.divisions = const [],
    this.currentDivision,
    this.users = const [],
    this.currentUser,
    this.timeLeft,
  });

  LeaderboardState copyWith({
    DivisionEntity? currentDivision,
    List<DivisionEntity>? divisions,
    List<UserDivisionEntity>? users,
    UserDivisionEntity? currentUser,
    TimeEntity? timeLeft,
  }) {
    return LeaderboardState(
      divisions: divisions ?? this.divisions,
      currentDivision: currentDivision ?? this.currentDivision,
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

enum LeaderboardStatus {
  bronze,
  silver,
  gold,
  sapphire,
  ruby,
  emerald,
  amethyst,
  pearl,
  obsidian,
  diamond,
}
