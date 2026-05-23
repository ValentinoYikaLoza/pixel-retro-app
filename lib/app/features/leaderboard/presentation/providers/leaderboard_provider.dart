import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:pixel_retro_app/app/features/leaderboard/data/mappers/user_mapper.dart';
import 'package:pixel_retro_app/app/features/time/presentation/providers/time_provider.dart';
import 'package:pixel_retro_app/app/shared/layouts/presentation/providers/user_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/internet_status_provider.dart';
import 'package:pixel_retro_app/app/shared/providers/web_socket_provider.dart';
import 'package:pixel_retro_app/di.dart';

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
      return LeaderboardNotifier(ref);
    });

/// Carga los datos de la pantalla de leaderboard (se recarga al re-entrar).
final leaderboardInitProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.watch(userInitProvider.future);
  await ref.watch(timeInitProvider.future);
  final notifier = ref.read(leaderboardProvider.notifier);
  // Divisiones y usuarios son independientes: cargan en paralelo.
  await Future.wait([notifier.getDivisions(), notifier.getUsers()]);
});

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier(this.ref) : super(LeaderboardState()) {
    _init();
  }

  final Ref ref;
  final LeaderboardRepository repository = getIt<LeaderboardRepository>();

  StreamSubscription<Map<String, dynamic>>? _usersSub;

  void _init() {
    ref.listen<bool>(
      internetStatusProvider.select((async) => async.value ?? false),
      (previous, hasInternet) {
        if (!hasInternet) {
          initData();
        }
      },
    );
  }

  void initData() async {
    state = state.copyWith(divisions: const [], users: const []);
  }

  Future<void> initDataUser() async {
    // Obtiene la instancia del socket desde Riverpod
    final socket = ref.read(websocketServiceProvider);
    // Evita suscripciones duplicadas si se recarga la pantalla.
    await _usersSub?.cancel();
    // 📊 Escucha las estadísticas en tiempo real
    _usersSub = socket.usersStream.listen((data) {
      final users = UserMapper.fromSocketData(data);
      state = state.copyWith(users: users);
    });
  }

  /// Tamaño de página de la ventana de usuarios (paginación cliente).
  static const int pageSize = 20;

  /// Carga inicial vía HTTP + suscripción a actualizaciones en vivo.
  /// Lanza [ServiceException] si falla; la UI lo maneja vía AsyncValue.
  Future<void> getUsers() async {
    await initDataUser();
    final users = await repository.getUsers();
    state = state.copyWith(users: users, visibleUserCount: pageSize);
  }

  /// Muestra la siguiente página de usuarios (sobre la lista ya cargada).
  void loadMoreUsers() {
    if (!state.hasMoreUsers) return;
    state = state.copyWith(visibleUserCount: state.visibleUserCount + pageSize);
  }

  String getDivision() {
    final userState = ref.read(userProvider);

    final divisions = state.divisions;

    if (divisions.isEmpty) return '';

    final DivisionEntity currentDivision = divisions.firstWhere(
      (division) => division.id == userState.divisionId,
      orElse: () => DivisionEntity(id: 0, name: ''),
    );

    final divisionName = currentDivision.name;

    return divisionName;
  }

  /// Lanza [ServiceException] si falla; la UI lo maneja vía AsyncValue.
  Future<void> getDivisions() async {
    final divisions = await repository.getDivisions();
    state = state.copyWith(divisions: divisions);
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

class LeaderboardState extends Equatable {
  final List<DivisionEntity> divisions;
  final List<UserDivisionEntity> users;

  /// Cuántos usuarios se muestran (ventana de paginación cliente).
  final int visibleUserCount;

  const LeaderboardState({
    this.divisions = const [],
    this.users = const [],
    this.visibleUserCount = LeaderboardNotifier.pageSize,
  });

  /// Usuarios efectivamente visibles según la ventana actual.
  List<UserDivisionEntity> get visibleUsers =>
      users.take(visibleUserCount).toList();

  /// Quedan usuarios por mostrar.
  bool get hasMoreUsers => visibleUserCount < users.length;

  LeaderboardState copyWith({
    List<DivisionEntity>? divisions,
    List<UserDivisionEntity>? users,
    int? visibleUserCount,
  }) {
    return LeaderboardState(
      divisions: divisions ?? this.divisions,
      users: users ?? this.users,
      visibleUserCount: visibleUserCount ?? this.visibleUserCount,
    );
  }

  @override
  List<Object?> get props => [divisions, users, visibleUserCount];
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
