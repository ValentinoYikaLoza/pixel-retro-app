import 'package:pixel_retro_app/app/features/home/presentation/providers/home_provider.dart';

final List<GameModel> gameData = [
  GameModel(
    game: Game.snake,
    title: 'Snake Game',
    imagePath: 'assets/images/snake.png',
  ),
  GameModel(
    game: Game.tetris,
    title: 'Tetris Game',
    imagePath: 'assets/images/tetris.png',
  ),
  GameModel(
    game: Game.pixelInvader,
    title: 'Pixel Invader Game',
    imagePath: 'assets/images/invader.png',
  ),
  GameModel(
    game: Game.pacman,
    title: 'Pac-man Game',
    imagePath: 'assets/images/pacman.png',
  ),
];
