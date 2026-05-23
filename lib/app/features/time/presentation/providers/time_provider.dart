import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pixel_retro_app/app/features/time/domain/repositories/time_repository.dart';
import 'package:pixel_retro_app/di.dart';

final timeProvider = StateNotifierProvider<TimeNotifier, TimeState>((ref) {
  return TimeNotifier(ref);
});

/// Carga la hora del servidor una sola vez (mantiene el ticker activo).
final timeInitProvider = FutureProvider<void>((ref) async {
  await ref.read(timeProvider.notifier).getTime();
});

class TimeNotifier extends StateNotifier<TimeState>
    with WidgetsBindingObserver {
  TimeNotifier(this.ref) : super(const TimeState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final Ref ref;
  final TimeRepository repository = getIt<TimeRepository>();

  /// Reloj monótono: mide el tiempo transcurrido real desde la sincronización,
  /// inmune a que el usuario cambie la hora del dispositivo.
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;

  /// Lanza [ServiceException] si falla; la UI lo maneja vía AsyncValue.
  Future<void> getTime() async {
    final serverDate = await repository.getTime(); // instante UTC del servidor
    _watch
      ..reset()
      ..start();
    state = state.copyWith(serverDate: serverDate);

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  /// Hora actual del servidor (UTC) = base + transcurrido monótono.
  DateTime? _syncedNow() {
    final base = state.serverDate;
    if (base == null) return null;
    return base.add(_watch.elapsed);
  }

  /// Un solo ticker (1s) recalcula mes, clave de período y los countdowns. Las
  /// fronteras se calculan en UTC: los resets son globales y coinciden con las
  /// ventanas del backend.
  void _tick() {
    final now = _syncedNow();
    if (now == null) return;

    final sunday = now.add(Duration(days: 7 - now.weekday));
    final lastDay = DateTime.utc(now.year, now.month + 1, 0);

    state = state.copyWith(
      currentMonth: _monthMap[DateFormat('MMMM').format(now)] ?? '',
      // Clave de día (UTC): cambia al cruzar cualquier frontera (las de semana
      // y mes también ocurren en un cambio de día). La UI la observa.
      periodKey: '${now.year}-${now.month}-${now.day}',
      timeUntilNextDay: _computeDifference(
        now,
        DateTime.utc(now.year, now.month, now.day + 1),
      ),
      timeUntilNextSeason: _computeDifference(
        now,
        DateTime.utc(sunday.year, sunday.month, sunday.day, 20, 0),
      ),
      timeUntilNextWeek: _computeDifference(
        now,
        DateTime.utc(sunday.year, sunday.month, sunday.day + 1),
      ),
      timeUntilNextMonth: _computeDifference(
        now,
        DateTime.utc(lastDay.year, lastDay.month, lastDay.day + 1),
      ),
    );
  }

  TimeEntity _computeDifference(DateTime now, DateTime target) {
    final diff = target.difference(now);
    if (diff.inSeconds < 60) {
      return TimeEntity(time: diff.inSeconds, unit: TimeUnit.seconds);
    } else if (diff.inMinutes < 60) {
      return TimeEntity(time: diff.inMinutes, unit: TimeUnit.minutes);
    } else if (diff.inHours < 24) {
      return TimeEntity(time: diff.inHours, unit: TimeUnit.hours);
    } else {
      return TimeEntity(time: diff.inDays, unit: TimeUnit.days);
    }
  }

  /// Al volver del background re-sincroniza con el servidor (corrige el drift
  /// acumulado durante la suspensión).
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed && state.serverDate != null) {
      getTime();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }
}

class TimeState extends Equatable {
  final DateTime? serverDate;
  final String currentMonth;

  /// Clave de día (UTC). Cambia al cruzar la frontera de período; la UI la
  /// observa para refrescar las misiones.
  final String periodKey;
  final TimeEntity timeUntilNextDay;
  final TimeEntity timeUntilNextSeason;
  final TimeEntity timeUntilNextWeek;
  final TimeEntity timeUntilNextMonth;

  const TimeState({
    this.serverDate,
    this.currentMonth = '',
    this.periodKey = '',
    this.timeUntilNextDay = const TimeEntity(),
    this.timeUntilNextSeason = const TimeEntity(),
    this.timeUntilNextWeek = const TimeEntity(),
    this.timeUntilNextMonth = const TimeEntity(),
  });

  TimeState copyWith({
    DateTime? serverDate,
    String? currentMonth,
    String? periodKey,
    TimeEntity? timeUntilNextDay,
    TimeEntity? timeUntilNextSeason,
    TimeEntity? timeUntilNextWeek,
    TimeEntity? timeUntilNextMonth,
  }) {
    return TimeState(
      serverDate: serverDate ?? this.serverDate,
      currentMonth: currentMonth ?? this.currentMonth,
      periodKey: periodKey ?? this.periodKey,
      timeUntilNextDay: timeUntilNextDay ?? this.timeUntilNextDay,
      timeUntilNextSeason: timeUntilNextSeason ?? this.timeUntilNextSeason,
      timeUntilNextWeek: timeUntilNextWeek ?? this.timeUntilNextWeek,
      timeUntilNextMonth: timeUntilNextMonth ?? this.timeUntilNextMonth,
    );
  }

  @override
  List<Object?> get props => [
    serverDate,
    currentMonth,
    periodKey,
    timeUntilNextDay,
    timeUntilNextSeason,
    timeUntilNextWeek,
    timeUntilNextMonth,
  ];
}

final _monthMap = {
  'January': 'ENERO',
  'February': 'FEBRERO',
  'March': 'MARZO',
  'April': 'ABRIL',
  'May': 'MAYO',
  'June': 'JUNIO',
  'July': 'JULIO',
  'August': 'AGOSTO',
  'September': 'SEPTIEMBRE',
  'October': 'OCTUBRE',
  'November': 'NOVIEMBRE',
  'December': 'DICIEMBRE',
};

enum TimeUnit { seconds, minutes, hours, days }

class TimeEntity extends Equatable {
  final int? time;
  final TimeUnit? unit;
  const TimeEntity({this.time, this.unit});

  @override
  List<Object?> get props => [time, unit];
}
