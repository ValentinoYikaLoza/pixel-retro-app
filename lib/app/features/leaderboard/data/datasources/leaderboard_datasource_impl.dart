import 'package:pixel_retro_app/app/features/leaderboard/domain/datasources/leaderboard_datasource.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/division_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/time_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/entities/user_rank_entity.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_current_division_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_current_user_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_time_left_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_division_list_response_model.dart';
import 'package:pixel_retro_app/app/features/leaderboard/domain/models/get_user_list_response_model.dart';

class LeaderboardDatasourceImpl implements LeaderboardDatasource {
  @override
  Future<GetUserListResponseModel> getUsers() {
    return Future.delayed(Duration(milliseconds: 200), () {
      return GetUserListResponseModel(
        users: [
          UserDivisionEntity(
            id: 1,
            name: 'Valentino',
            score: 1000,
            timesRankedFirst: 6,
          ),
          UserDivisionEntity(
            id: 2,
            name: 'Sergio',
            score: 1150,
            timesRankedFirst: 4,
          ),
          UserDivisionEntity(
            id: 3,
            name: 'Mateo',
            score: 1100,
            timesRankedFirst: 3,
          ),
          UserDivisionEntity(
            id: 4,
            name: 'Sofia',
            score: 1050,
            timesRankedFirst: 2,
          ),
          UserDivisionEntity(
            id: 5,
            name: 'Martina',
            score: 1000,
            timesRankedFirst: 2,
          ),
          UserDivisionEntity(
            id: 6,
            name: 'Thiago',
            score: 950,
            timesRankedFirst: 1,
          ),
          UserDivisionEntity(
            id: 7,
            name: 'Camila',
            score: 900,
            timesRankedFirst: 1,
          ),
          UserDivisionEntity(
            id: 8,
            name: 'Benjamin',
            score: 850,
            timesRankedFirst: 1,
          ),
          UserDivisionEntity(
            id: 9,
            name: 'Emma',
            score: 800,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 10,
            name: 'Juan',
            score: 780,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 11,
            name: 'Mia',
            score: 760,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 12,
            name: 'Pedro',
            score: 740,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 13,
            name: 'Isabella',
            score: 720,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 14,
            name: 'Diego',
            score: 700,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 15,
            name: 'Antonella',
            score: 680,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 16,
            name: 'Joaquin',
            score: 660,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 17,
            name: 'Catalina',
            score: 640,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 18,
            name: 'Facundo',
            score: 620,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 19,
            name: 'Agustina',
            score: 600,
            timesRankedFirst: 0,
          ),
          UserDivisionEntity(
            id: 20,
            name: 'Santiago',
            score: 580,
            timesRankedFirst: 0,
          ),
        ],
      );
    });
  }

  @override
  Future<GetDivisionListResponseModel> getDivisions() {
    return Future.delayed(Duration(milliseconds: 200), () {
      return GetDivisionListResponseModel(
        divisions: [
          DivisionEntity(id: 1, name: 'División Bronce'),
          DivisionEntity(id: 2, name: 'División Plata'),
          DivisionEntity(id: 3, name: 'División Oro'),
          DivisionEntity(id: 4, name: 'División Zafiro'),
          DivisionEntity(id: 5, name: 'División Rubí'),
          DivisionEntity(id: 6, name: 'División Esmeralda'),
          DivisionEntity(id: 7, name: 'División Amatista'),
          DivisionEntity(id: 8, name: 'División Perla'),
          DivisionEntity(id: 9, name: 'División Obsidiana'),
          DivisionEntity(id: 10, name: 'División Diamante'),
        ],
      );
    });
  }

  @override
  Future<GetTimeLeftResponseModel> getTimeLeft() {
    return Future.delayed(Duration(milliseconds: 200), () {
      return GetTimeLeftResponseModel(
        timeLeft: TimeEntity(time: 5, unit: 'MINUTOS'),
      );
    });
  }

  @override
  Future<GetCurrentDivisionResponseModel> getCurrentDivision() {
    return Future.delayed(Duration(milliseconds: 200), () {
      return GetCurrentDivisionResponseModel(
        currentDivision: DivisionEntity(id: 1, name: 'División Bronce'),
      );
    });
  }

  @override
  Future<GetCurrentUserResponseModel> getCurrentUser() {
    return Future.delayed(Duration(milliseconds: 200), () {
      return GetCurrentUserResponseModel(
        currentUser: UserDivisionEntity(
          id: 1,
          name: 'Valentino',
          score: 1200,
          timesRankedFirst: 6,
        ),
      );
    });
  }
}
