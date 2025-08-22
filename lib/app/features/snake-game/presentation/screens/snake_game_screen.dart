import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_retro_app/app/features/snake-game/presentation/providers/snake_game_provider.dart';

class SnakeGameScreen extends ConsumerStatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  SnakeGameScreenState createState() => SnakeGameScreenState();
}

class SnakeGameScreenState extends ConsumerState<SnakeGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // pon la pantalla horizontal y que sea full screen
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      // ref.read(snakeGameProvider.notifier).initGame();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Game Area')));
  }
}
