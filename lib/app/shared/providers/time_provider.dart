import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/shared/models/get_time_list_response_model.dart';
import 'package:pixel_retro_app/app/shared/providers/data/time_mapper.dart';
import 'package:pixel_retro_app/app/shared/providers/web_socket_provider.dart';

final timeProvider = StateNotifierProvider<TimeNotifier, TimeState>((ref) {
  return TimeNotifier(ref);
});

class TimeNotifier extends StateNotifier<TimeState> {
  TimeNotifier(this.ref) : super(const TimeState());

  final Ref ref;
  StreamSubscription<Map<String, dynamic>>? _timeSub;

  Future<void> initData() async {
    // Obtiene la instancia del socket desde Riverpod
    final socket = ref.read(websocketServiceProvider);
    // 📊 Escucha las estadísticas en tiempo real
    _timeSub = socket.timeListStream.listen((time) {
      // print('📊 [LeaderboardNotifier] Users recibidos: $users');

      final GetTimeListResponseModel timeListModel = TimeMapper.fromSocketData(
        time,
      );
      state = state.copyWith(timeList: timeListModel);
    });
  }

  @override
  void dispose() {
    _timeSub?.cancel();
    super.dispose();
  }
}

class TimeState {
  final GetTimeListResponseModel? timeList;

  const TimeState({this.timeList});

  TimeState copyWith({GetTimeListResponseModel? timeList}) {
    return TimeState(timeList: timeList ?? this.timeList);
  }
}

class TimeEntity {
  final int time;
  final String unit;

  TimeEntity({required this.time, required this.unit});
}
