import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/game_state.dart';
import 'components/snake_player.dart';
import 'components/environment.dart';

class SnakeHunterGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks {
  final GameState gameState;
  late SnakePlayer snake;
  late Environment environment;
  double _timerAcc = 0;

  SnakeHunterGame(this.gameState);

  @override
  Future<void> onLoad() async {
    // Load background
    environment = Environment();
    add(environment);

    // Initialize snake
    snake = SnakePlayer();
    add(snake);

    // Spawn some prey
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      PreyAnimal prey;
      int type = random.nextInt(3);
      if (type == 0) {
        prey = Rat();
      } else if (type == 1) {
        prey = Rabbit();
      } else {
        prey = Frog();
      }
      prey.position = Vector2(
        random.nextDouble() * size.x,
        random.nextDouble() * size.y,
      );
      add(prey);
    }

    // Setup camera
    camera.follow(snake);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    snake.moveTowards(event.localPosition);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameState.status == GameStatus.playing) {
      _timerAcc += dt;
      if (_timerAcc >= 1.0) {
        gameState.tick();
        _timerAcc = 0;
      }
      
      if (gameState.status == GameStatus.gameOver) {
        overlays.add('GameOver');
        overlays.remove('HUD');
        paused = true;
      }
    }
  }

  @override
  Color backgroundColor() => const Color(0xFFF5F5F5);
}
