import 'package:equatable/equatable.dart';

class UserDivisionEntity extends Equatable {
  final int id;
  final String name;
  final int score;
  final int timesRankedFirst;
  final String flag;

  const UserDivisionEntity({
    required this.id,
    required this.name,
    required this.score,
    required this.timesRankedFirst,
    required this.flag,
  });

  @override
  List<Object?> get props => [id, name, score, timesRankedFirst, flag];
}
