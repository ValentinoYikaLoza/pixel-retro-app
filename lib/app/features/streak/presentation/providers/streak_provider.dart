import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/streak/domain/entities/streak_overview_entity.dart';
import 'package:pixel_retro_app/app/features/streak/domain/repositories/streak_repository.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final streakProvider =
    StateNotifierProvider.autoDispose<StreakNotifier, StreakState>((ref) {
      return StreakNotifier();
    });

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier() : super(const StreakState()) {
    load();
  }

  final StreakRepository _repository = getIt<StreakRepository>();

  Future<void> load() async {
    state = state.copyWith(loading: true, error: () => null);
    try {
      final overview = await _repository.getStreak();
      if (!mounted) return;
      state = state.copyWith(loading: false, overview: () => overview);
    } on ServiceException catch (e) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: () => e.message);
    }
  }

  /// Reclama una meta mensual. El backend valida y devuelve el resumen nuevo.
  Future<void> claimGoal(int goalId) async {
    if (state.busy) return;
    state = state.copyWith(busy: true);
    try {
      final overview = await _repository.claimGoal(goalId);
      if (!mounted) return;
      state = state.copyWith(busy: false, overview: () => overview);
      SnackbarService.show('¡Recompensa reclamada!', type: SnackbarType.success);
    } on ServiceException catch (e) {
      if (!mounted) return;
      state = state.copyWith(busy: false);
      SnackbarService.show(e.message, type: SnackbarType.error);
    }
  }

  /// Compra un congelador con monedas.
  Future<void> buyFreeze() async {
    if (state.busy) return;
    state = state.copyWith(busy: true);
    try {
      final overview = await _repository.buyFreeze();
      if (!mounted) return;
      state = state.copyWith(busy: false, overview: () => overview);
      SnackbarService.show('¡Congelador comprado!', type: SnackbarType.success);
    } on ServiceException catch (e) {
      if (!mounted) return;
      state = state.copyWith(busy: false);
      SnackbarService.show(e.message, type: SnackbarType.error);
    }
  }
}

class StreakState extends Equatable {
  final StreakOverviewEntity? overview;
  final bool loading;

  /// Acción (reclamar/comprar) en curso, para deshabilitar botones.
  final bool busy;
  final String? error;

  const StreakState({
    this.overview,
    this.loading = false,
    this.busy = false,
    this.error,
  });

  StreakState copyWith({
    StreakOverviewEntity? Function()? overview,
    bool? loading,
    bool? busy,
    String? Function()? error,
  }) {
    return StreakState(
      overview: overview != null ? overview() : this.overview,
      loading: loading ?? this.loading,
      busy: busy ?? this.busy,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [overview, loading, busy, error];
}
