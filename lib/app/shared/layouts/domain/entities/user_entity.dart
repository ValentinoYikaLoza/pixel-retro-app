class UserEntity {
  final int id;
  final String name;
  final int coins;
  final int lives;
  final int streak;
  final int exp;

  UserEntity({
    required this.id,
    required this.name,
    required this.exp,
    required this.coins,
    required this.lives,
    required this.streak,
  });
}
