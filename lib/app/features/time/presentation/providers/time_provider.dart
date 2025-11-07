import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pixel_retro_app/app/features/time/domain/models/get_time_response_model.dart';
import 'package:pixel_retro_app/app/features/time/domain/repositories/time_repository.dart';
import 'package:pixel_retro_app/app/shared/enums/snackbar_type.dart';
import 'package:pixel_retro_app/app/shared/models/service_exception.dart';
import 'package:pixel_retro_app/app/shared/services/snackbar_service.dart';
import 'package:pixel_retro_app/di.dart';

final timeProvider = StateNotifierProvider<TimeNotifier, TimeState>((ref) {
  return TimeNotifier(ref);
});

class TimeNotifier extends StateNotifier<TimeState> {
  TimeNotifier(this.ref) : super(TimeState());

  final Ref ref;
  final TimeRepository repository = getIt<TimeRepository>();

  Timer? _monthTimer;
  Timer? _nextDayTimer;
  Timer? _nextSeasonTimer;
  Timer? _nextWeekTimer;
  Timer? _nextMonthTimer;

  Future<void> getTime() async {
    try {
      final GetTimeResponseModel response = await repository.getTime();
      state = state.copyWith(
        serverDate: response.currentDate,
        receivedAt: DateTime.now(),
      );
      _startMonthStream();
      _startTimeUntilStreams();
    } on ServiceException {
      SnackbarService.show(
        'Error obteniendo el tiempo',
        type: SnackbarType.error,
      );
    }
  }

  void _startMonthStream() {
    _monthTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = state.currentDateSynced;
      if (now == null) return;

      final name = _monthMap[DateFormat('MMMM').format(now)] ?? '';
      state = state.copyWith(currentMonth: name);
    });
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

  void _startTimeUntilStreams() {
    _nextDayTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = state.currentDateSynced;
      if (now == null) return;
      final target = DateTime(now.year, now.month, now.day + 1);
      state = state.copyWith(timeUntilNextDay: _computeDifference(now, target));
    });

    _nextSeasonTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = state.currentDateSynced;
      if (now == null) return;
      final next = now.add(Duration(days: 7 - now.weekday));
      final target = DateTime(next.year, next.month, next.day, 20, 0);
      state = state.copyWith(
        timeUntilNextSeason: _computeDifference(now, target),
      );
    });

    _nextWeekTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = state.currentDateSynced;
      if (now == null) return;
      final nextSunday = now.add(Duration(days: 7 - now.weekday));
      final target = DateTime(
        nextSunday.year,
        nextSunday.month,
        nextSunday.day + 1,
      );
      state = state.copyWith(
        timeUntilNextWeek: _computeDifference(now, target),
      );
    });

    _nextMonthTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = state.currentDateSynced;
      if (now == null) return;
      final lastDay = DateTime(now.year, now.month + 1, 0);
      final target = DateTime(lastDay.year, lastDay.month, lastDay.day + 1);
      state = state.copyWith(
        timeUntilNextMonth: _computeDifference(now, target),
      );
    });
  }

  @override
  void dispose() {
    _monthTimer?.cancel();
    _nextDayTimer?.cancel();
    _nextSeasonTimer?.cancel();
    _nextWeekTimer?.cancel();
    _nextMonthTimer?.cancel();
    super.dispose();
  }
}

class TimeState {
  final DateTime? serverDate;
  final DateTime? receivedAt;
  final String currentMonth;
  final TimeEntity timeUntilNextDay;
  final TimeEntity timeUntilNextSeason;
  final TimeEntity timeUntilNextWeek;
  final TimeEntity timeUntilNextMonth;

  TimeState({
    this.serverDate,
    this.receivedAt,
    this.currentMonth = '',
    this.timeUntilNextDay = const TimeEntity(),
    this.timeUntilNextSeason = const TimeEntity(),
    this.timeUntilNextWeek = const TimeEntity(),
    this.timeUntilNextMonth = const TimeEntity(),
  });

  DateTime? get currentDateSynced {
    if (serverDate == null || receivedAt == null) return null;
    return serverDate!.add(DateTime.now().difference(receivedAt!)).toLocal();
  }

  TimeState copyWith({
    DateTime? serverDate,
    DateTime? receivedAt,
    String? currentMonth,
    TimeEntity? timeUntilNextDay,
    TimeEntity? timeUntilNextSeason,
    TimeEntity? timeUntilNextWeek,
    TimeEntity? timeUntilNextMonth,
  }) {
    return TimeState(
      serverDate: serverDate ?? this.serverDate,
      receivedAt: receivedAt ?? this.receivedAt,
      currentMonth: currentMonth ?? this.currentMonth,
      timeUntilNextDay: timeUntilNextDay ?? this.timeUntilNextDay,
      timeUntilNextSeason: timeUntilNextSeason ?? this.timeUntilNextSeason,
      timeUntilNextWeek: timeUntilNextWeek ?? this.timeUntilNextWeek,
      timeUntilNextMonth: timeUntilNextMonth ?? this.timeUntilNextMonth,
    );
  }
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

class TimeEntity {
  final int? time;
  final TimeUnit? unit;
  const TimeEntity({this.time, this.unit});
}
