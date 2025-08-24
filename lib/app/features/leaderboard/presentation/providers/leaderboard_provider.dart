import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/data/status_data.dart';
import 'package:pixel_retro_app/app/features/leaderboard/presentation/data/user_data.dart';

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
      return LeaderboardNotifier(ref);
    });

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier(this.ref) : super(LeaderboardState());

  final Ref ref;

  void initStatus() {
    state = state.copyWith(
      currentStatus: statusData[5],
      status: statusData,
      users: userData,
      currentUser: userData[0],
      today: () => DateTime.now(),
    );
  }
}

class LeaderboardState {
  final List<LeaderboardModel> status;
  final LeaderboardModel? currentStatus;
  final List<UserModel> users;
  final UserModel? currentUser;
  final DateTime? today;

  String get timeLeftUntilEndOfSunday {
    if (today == null) return '0 SEGUNDOS';

    // Find next Monday (weekday == 1)
    final now = DateTime.now();
    final endOfSunday = DateTime(
      now.year,
      now.month,
      now.day + (7 - now.weekday),
      23,
      59,
      59,
    );

    final duration = endOfSunday.difference(now);
    if (duration.inDays > 0) {
      return '${duration.inDays} DÍA${duration.inDays > 1 ? 'S' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} HORA${duration.inHours > 1 ? 'S' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} MINUTO${duration.inMinutes > 1 ? 'S' : ''}';
    } else {
      return '${duration.inSeconds} SEGUNDO${duration.inSeconds > 1 ? 'S' : ''}';
    }
  }

  LeaderboardState({
    this.status = const [],
    this.currentStatus,
    this.users = const [],
    this.currentUser,
    this.today,
  });

  LeaderboardState copyWith({
    List<LeaderboardModel>? status,
    LeaderboardModel? currentStatus,
    List<UserModel>? users,
    UserModel? currentUser,
    ValueGetter<DateTime>? today,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      currentStatus: currentStatus ?? this.currentStatus,
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
      today: today != null ? today() : this.today,
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

class LeaderboardModel {
  final LeaderboardStatus status;
  final String title;
  final String activePath;
  final String inactivePath;

  LeaderboardModel({
    required this.status,
    required this.title,
    required this.activePath,
    required this.inactivePath,
  });
}

class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final int score;
  final int rank;
  final int timesRankedFirst;

  UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.rank,
    required this.timesRankedFirst,
  });
}
