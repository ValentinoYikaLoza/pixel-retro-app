import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixel_retro_app/app/features/time/presentation/providers/time_provider.dart';

enum TimeWidgetType {
  timeUntilNextDay,
  timeUntilNextWeek,
  timeUntilNextMonth,
  timeUntilNextSeason,
}

class TimeWidget extends ConsumerStatefulWidget {
  const TimeWidget({
    super.key,
    required this.type,
    required this.color,
    this.fontSize = 18,
    this.showTheTextComplete = false,
  });

  final TimeWidgetType type;
  final Color color;
  final double fontSize;
  final bool showTheTextComplete;

  @override
  TimeWidgetState createState() => TimeWidgetState();
}

class TimeWidgetState extends ConsumerState<TimeWidget> {
  timeUnitMapper(TimeUnit? unit, int? time) {
    if (unit == null) return '';
    if (time == null) return '';

    switch (unit) {
      case TimeUnit.seconds:
        if (time == 1) {
          return 'SEGUNDO';
        }
        return 'SEGUNDOS';
      case TimeUnit.minutes:
        if (time == 1) {
          return 'MINUTO';
        }
        return 'MINUTOS';
      case TimeUnit.hours:
        if (time == 1) {
          return 'HORA';
        }
        return 'HORAS';
      case TimeUnit.days:
        if (time == 1) {
          return 'DÍA';
        }
        return 'DÍAS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeState = ref.watch(timeProvider);

    switch (widget.type) {
      case TimeWidgetType.timeUntilNextDay:
        return _buildTimeWidget(
          time: timeState.timeUntilNextDay.time,
          unit: timeUnitMapper(
            timeState.timeUntilNextDay.unit,
            timeState.timeUntilNextDay.time,
          ),
          color: widget.color,
          fontSize: widget.fontSize,
          showTheTextComplete: widget.showTheTextComplete,
        );
      case TimeWidgetType.timeUntilNextWeek:
        return _buildTimeWidget(
          time: timeState.timeUntilNextWeek.time,
          unit: timeUnitMapper(
            timeState.timeUntilNextWeek.unit,
            timeState.timeUntilNextWeek.time,
          ),
          color: widget.color,
          fontSize: widget.fontSize,
          showTheTextComplete: widget.showTheTextComplete,
        );
      case TimeWidgetType.timeUntilNextMonth:
        return _buildTimeWidget(
          time: timeState.timeUntilNextMonth.time,
          unit: timeUnitMapper(
            timeState.timeUntilNextMonth.unit,
            timeState.timeUntilNextMonth.time,
          ),
          color: widget.color,
          fontSize: widget.fontSize,
          showTheTextComplete: widget.showTheTextComplete,
        );
      case TimeWidgetType.timeUntilNextSeason:
        return _buildTimeWidget(
          time: timeState.timeUntilNextSeason.time,
          unit: timeUnitMapper(
            timeState.timeUntilNextSeason.unit,
            timeState.timeUntilNextSeason.time,
          ),
          color: widget.color,
          fontSize: widget.fontSize,
          showTheTextComplete: widget.showTheTextComplete,
        );
    }
  }

  Widget _buildTimeWidget({
    required int? time,
    required String unit,
    required Color color,
    required double fontSize,
    required bool showTheTextComplete,
  }) {
    if (time == null) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Spin(
          infinite: true,
          child: SvgPicture.asset(
            'assets/icons/clock.svg',
            width: fontSize + 2,
            height: fontSize + 2,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${showTheTextComplete ? "QUEDAN " : ""}$time $unit',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
