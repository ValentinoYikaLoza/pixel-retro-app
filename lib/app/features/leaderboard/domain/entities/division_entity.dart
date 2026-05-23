import 'package:equatable/equatable.dart';

class DivisionEntity extends Equatable {
  final int id;
  final String name;

  const DivisionEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
