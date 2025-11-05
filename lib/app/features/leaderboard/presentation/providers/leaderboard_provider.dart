import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_user_list_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/data/user_mapper.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/providers/web_socket_provider.dart';
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

  StreamSubscription<Map<String, dynamic>>? _usersSub;

  Future<void> initDataUser() async {
    // Obtiene la instancia del socket desde Riverpod
    final socket = ref.read(websocketServiceProvider);
    // 📊 Escucha las estadísticas en tiempo real
    _usersSub = socket.usersStream.listen((users) {
      // print('📊 [LeaderboardNotifier] Users recibidos: $users');

      final GetUserListResponseModel model = UserMapper.fromSocketData(users);
      // print('📊 [Provider] Usuarios actuales: ${model.users[0].name}');
      state = state.copyWith(users: model.users);
    });
  }

  Future<void> getUsers() async {
    try {
      await initDataUser();
      await repository.getUsers();
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

  String getDivisionImage(int index, int divisionId) {
    if (divisionId == 0) {
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

    return index <= divisionId
        ? divisionActiveImageList[index - 1]
        : divisionInactiveImageList[index - 1];
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }
}

class LeaderboardState {
  final List<DivisionEntity> divisions;
  final List<UserDivisionEntity> users;

  LeaderboardState({this.divisions = const [], this.users = const []});

  LeaderboardState copyWith({
    List<DivisionEntity>? divisions,
    List<UserDivisionEntity>? users,
  }) {
    return LeaderboardState(
      divisions: divisions ?? this.divisions,
      users: users ?? this.users,
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
