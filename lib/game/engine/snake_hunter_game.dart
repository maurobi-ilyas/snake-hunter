import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../services/game_state.dart';
import '../../services/performance_monitor.dart';
import 'physics/collision_grid.dart';
import '../components/snake_player.dart';
import '../components/environment.dart';
import '../components/prey_animal.dart';
import '../../services/prey_pool.dart';
import '../../services/particle_pool.dart';

class SnakeHunterGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks {
  final GameState gameState;
  late SnakePlayer snake;
  late Environment environment;
  late JoystickComponent joystick;
  final PreyPool preyPool = PreyPool();
  final ParticlePool particlePool = ParticlePool();
  double _timerAcc = 0;
  double elapsedTime = 0;
  final CollisionGrid collisionGrid = CollisionGrid();
  double timeScale = 1.0;

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
    final scaledDt = dt * timeScale;
    super.update(scaledDt);
    elapsedTime += dt;
    PerformanceMonitor.recordFrame(dt);
    
    if (gameState.status == GameStatus.playing) {
      _timerAcc += dt;
      if (_timerAcc >= 1.0) {
        gameState.tick();
        _timerAcc = 0;
      }
      
      if (gameState.timeLeft <= 0) {
        // AAA Game Over Slowdown
        timeScale = ui.lerpDouble(timeScale, 0.1, dt * 3) ?? 0.1;
        if (timeScale < 0.2) {
          gameState.setStatus(GameStatus.gameOver);
          paused = true;
        }
      }

      // Smart Camera System
      final targetZoom = 1.0 + (gameState.combo * 0.05);
      camera.viewfinder.zoom = ui.lerpDouble(camera.viewfinder.zoom, targetZoom, dt * 2) ?? 1.0;
      
      // Smooth Follow with Look-ahead
      final targetPosition = snake.position + (snake.velocity * 0.2);
      camera.viewfinder.position = ui.lerpDouble(camera.viewfinder.position.x, targetPosition.x, dt * 3) != null 
          ? Vector2(
              ui.lerpDouble(camera.viewfinder.position.x, targetPosition.x, dt * 3)!,
              ui.lerpDouble(camera.viewfinder.position.y, targetPosition.y, dt * 3)!,
            )
          : targetPosition;
    }
  }

  @override
  Color backgroundColor() => const Color(0xFFF5F5F5);
}
