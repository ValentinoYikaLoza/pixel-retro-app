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
      daysTillSunday: 3,
    );
  }
}

class LeaderboardState {
  final List<LeaderboardModel> status;
  final LeaderboardModel? currentStatus;
  final List<UserModel> users;
  final UserModel? currentUser;
  final int daysTillSunday;

  LeaderboardState({
    this.status = const [],
    this.currentStatus,
    this.users = const [],
    this.daysTillSunday = 0,
    this.currentUser,
  });

  LeaderboardState copyWith({
    List<LeaderboardModel>? status,
    LeaderboardModel? currentStatus,
    List<UserModel>? users,
    UserModel? currentUser,
    int? daysTillSunday,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      currentStatus: currentStatus ?? this.currentStatus,
      users: users ?? this.users,
      currentUser: currentUser ?? this.currentUser,
      daysTillSunday: daysTillSunday ?? this.daysTillSunday,
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
