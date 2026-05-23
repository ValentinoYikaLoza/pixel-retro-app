import 'package:equatable/equatable.dart';

class GameEntity extends Equatable {
  final int id;

  /// Clave estable (no editorial): el cliente la usa para el asset
  /// (`assets/images/{code}.png`) y la ruta (`/level-{code}-game`).
  final String code;
  final String title;

  const GameEntity({required this.id, required this.code, required this.title});

  @override
  List<Object?> get props => [id, code, title];
}
