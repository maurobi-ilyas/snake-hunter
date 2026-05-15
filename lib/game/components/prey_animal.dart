import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../engine/snake_hunter_game.dart';

enum AIState { idle, wandering, escaping, eaten }

class PreyAnimal extends SpriteComponent with HasGameRef<SnakeHunterGame>, CollisionCallbacks {
  final int type; // 0: Rat, 1: Rabbit, 2: Frog
  final double baseSpeed;
  
  AIState state = AIState.wandering;
  Vector2 velocity = Vector2.zero();
  double _stateTimer = 0;
  final math.Random _random = math.Random();
  
  PreyAnimal({required this.type, required this.baseSpeed}) : super(size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    _resetWander();
  }

  void _resetWander() {
    final angle = _random.nextDouble() * math.pi * 2;
    velocity = Vector2(math.cos(angle), math.sin(angle)) * baseSpeed;
    _stateTimer = 2 + _random.nextDouble() * 3;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state == AIState.eaten) return;

    // Adaptive Update Frequency
    final distanceToSnake = position.distanceTo(gameRef.snake.position);
    if (distanceToSnake < 300 || _stateTimer <= 0) {
      _updateAI(dt);
    }
    
    position += velocity * dt;

    // Boundary check
    if (position.x < 0) { position.x = 0; velocity.x *= -1; }
    if (position.x > gameRef.size.x) { position.x = gameRef.size.x; velocity.x *= -1; }
    if (position.y < 0) { position.y = 0; velocity.y *= -1; }
    if (position.y > gameRef.size.y) { position.y = gameRef.size.y; velocity.y *= -1; }
  }

  void _updateAI(double dt) {
    _stateTimer -= dt;

    // Detection logic
    final distanceToSnake = position.distanceTo(gameRef.snake.position);
    if (distanceToSnake < 150) {
      state = AIState.escaping;
      _stateTimer = 1.0;
    } else if (state == AIState.escaping && _stateTimer <= 0) {
      state = AIState.wandering;
      _resetWander();
    }

    switch (state) {
      case AIState.wandering:
        if (_stateTimer <= 0) _resetWander();
        break;
      case AIState.escaping:
        // Run away from snake
        final dir = (position - gameRef.snake.position).normalized();
        velocity = dir * baseSpeed * 2.0;
        break;
      default:
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Add a simple wobble if escaping
    if (state == AIState.escaping) {
      canvas.save();
      final wobble = math.sin(gameRef.elapsedTime * 20) * 0.1;
      canvas.scale(1.0 + wobble);
      canvas.restore();
    }
  }

  void onEaten() {
    state = AIState.eaten;
    removeFromParent();
  }
}
