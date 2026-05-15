import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/game_state.dart';
import 'components/snake_player.dart';
import 'components/environment.dart';
import 'components/prey_animal.dart';
import 'prey_pool.dart';

class SnakeHunterGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks {
  final GameState gameState;
  late SnakePlayer snake;
  late Environment environment;
  late JoystickComponent joystick;
  final PreyPool preyPool = PreyPool();
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

    // Setup Joystick
    final knobPaint = Paint()..color = Colors.white.withOpacity(0.5);
    final backgroundPaint = Paint()..color = Colors.white.withOpacity(0.2);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 50, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    // Spawn some prey
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      int type = random.nextInt(3);
      final prey = preyPool.get(type);
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
