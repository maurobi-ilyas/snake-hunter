import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/engine/snake_hunter_game.dart';
import 'ui/screens/main_menu.dart';
import 'services/game_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const SnakeHunterApp(),
    ),
  );
}

class SnakeHunterApp extends StatelessWidget {
  const SnakeHunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Hunter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MainMenu(),
    );
  }
}
