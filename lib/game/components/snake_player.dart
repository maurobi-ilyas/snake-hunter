import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'prey_animal.dart';
import '../snake_hunter_game.dart';
import '../../core/constants.dart';

class SnakePlayer extends PositionComponent with HasGameRef<SnakeHunterGame>, CollisionCallbacks {
  static const double baseSpeed = 200.0;
  Vector2 velocity = Vector2.zero();
  final List<Vector2> bodyPositions = [];
  final int initialLength = 5;
  late int currentLength;

  SnakePlayer() {
    currentLength = initialLength;
  }

  @override
  Future<void> onLoad() async {
    size = Vector2.all(36);
    anchor = Anchor.center;
    position = gameRef.size / 2;

    for (int i = 0; i < currentLength; i++) {
      bodyPositions.add(position.clone());
    }

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (velocity.length > 0) {
      position.add(velocity * dt);
      
      // Update body positions
      bodyPositions.insert(0, position.clone());
      if (bodyPositions.length > currentLength * 10) { // Gap between segments
        bodyPositions.removeLast();
      }

      double targetAngle = math.atan2(velocity.y, velocity.x);
      angle = targetAngle;
    }
  }

  @override
  void render(Canvas canvas) {
    // Render Body
    final bodyPaint = Paint()..color = const Color(0xFF81C784);
    for (int i = 1; i < currentLength; i++) {
      int index = i * 8; // Adjust for spacing
      if (index < bodyPositions.length) {
        Vector2 pos = bodyPositions[index];
        canvas.drawCircle(
          Offset(pos.x - position.x + size.x / 2, pos.y - position.y + size.y / 2),
          size.x / 2.5 * (1 - (i / (currentLength * 1.5))),
          bodyPaint,
        );
      }
    }

    // Render Head
    final headPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, headPaint);
    
    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.3), 6, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.7), 6, eyePaint);
    
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.3), 2.5, pupilPaint);
    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.7), 2.5, pupilPaint);
  }

  void moveTowards(Vector2 target) {
    velocity = (target - position).normalized() * baseSpeed;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PreyAnimal) {
      other.removeFromParent();
      gameRef.gameState.addScore(100);
      currentLength++;
      
      // Particles
      gameRef.add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 15,
            lifespan: 0.5,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2.random() * 200,
              speed: Vector2.random() * 100,
              position: position.clone(),
              child: CircleParticle(
                radius: 3,
                paint: Paint()..color = GameColors.accent,
              ),
            ),
          ),
        ),
      );

      // Visual feedback: brief scale up
      add(ScaleEffect.by(Vector2.all(1.2), EffectController(duration: 0.1, reverseDuration: 0.1)));
    }
  }
}
