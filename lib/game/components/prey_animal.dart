import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../snake_hunter_game.dart';
import 'snake_player.dart';

enum PreyState { idle, wandering, panic, escaping }

abstract class PreyAnimal extends PositionComponent with HasGameRef<SnakeHunterGame>, CollisionCallbacks {
  late PreyState state = PreyState.idle;
  double speed = 100.0;
  double fleeDistance = 150.0;
  Vector2 velocity = Vector2.zero();
  final math.Random _random = math.Random();
  double _stateTimer = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(30);
    anchor = Anchor.center;
    add(CircleHitbox());
    _setRandomWander();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final snake = gameRef.snake;
    final distanceToSnake = position.distanceTo(snake.position);

    if (distanceToSnake < fleeDistance) {
      state = PreyState.panic;
      _fleeFrom(snake.position);
    } else {
      _updateWander(dt);
    }

    position.add(velocity * dt);
    
    // Boundary check
    if (position.x < 0) position.x = 0;
    if (position.y < 0) position.y = 0;
    if (position.x > gameRef.canvasSize.x) position.x = gameRef.canvasSize.x;
    if (position.y > gameRef.canvasSize.y) position.y = gameRef.canvasSize.y;

    if (velocity.length > 0) {
      angle = math.atan2(velocity.y, velocity.x);
    }
  }

  void _fleeFrom(Vector2 target) {
    velocity = (position - target).normalized() * (speed * 1.5);
  }

  void _updateWander(double dt) {
    _stateTimer -= dt;
    if (_stateTimer <= 0) {
      _setRandomWander();
    }
  }

  void _setRandomWander() {
    state = PreyState.wandering;
    final angle = _random.nextDouble() * 2 * math.pi;
    velocity = Vector2(math.cos(angle), math.sin(angle)) * speed;
    _stateTimer = 1.0 + _random.nextDouble() * 2.0;
  }
}

class Rat extends PreyAnimal {
  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.grey;
    canvas.drawOval(size.toRect(), paint);
    
    // Tail
    final tailPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, size.y / 2), Offset(-10, size.y / 2), tailPaint);
  }
}

class Rabbit extends PreyAnimal {
  Rabbit() {
    speed = 150.0;
    fleeDistance = 200.0;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFF8BBD0); // Pastel Pink
    canvas.drawOval(size.toRect(), paint);
    
    // Ears
    canvas.drawOval(Rect.fromLTWH(size.x * 0.1, -10, 10, 20), paint);
    canvas.drawOval(Rect.fromLTWH(size.x * 0.5, -10, 10, 20), paint);
  }
}

class Frog extends PreyAnimal {
  Frog() {
    speed = 80.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Occasionally jump (burst of speed)
    if (math.Random().nextDouble() < 0.01) {
      velocity *= 5;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF4DB6AC); // Pastel Teal
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    
    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x * 0.2, size.y * 0.2), 6, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.2), 6, eyePaint);
  }
}
