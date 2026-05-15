import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'prey_animal.dart';
import 'floating_text.dart';
import '../engine/snake_hunter_game.dart';
import '../../services/particle_service.dart';
import '../../services/juice_service.dart';

class SnakePlayer extends PositionComponent with HasGameRef<SnakeHunterGame>, CollisionCallbacks {
  static const double baseSpeed = 220.0;
  Vector2 velocity = Vector2.zero();
  final List<Vector2> bodyPositions = [];
  final int initialLength = 5;
  late int currentLength;
  
  // Micro-animations state
  double _tongueTimer = 0;
  bool _isTongueOut = false;
  double _blinkTimer = 0;
  bool _isBlinking = false;

  SnakePlayer() {
    currentLength = initialLength;
  }

  @override
  Future<void> onLoad() async {
    size = Vector2.all(36);
    anchor = Anchor.center;
    position = gameRef.size / 2;

    for (int i = 0; i < currentLength * 10; i++) {
      bodyPositions.add(position.clone());
    }

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Joystick Movement
    if (!gameRef.joystick.relativeDelta.isZero()) {
      velocity = gameRef.joystick.relativeDelta * baseSpeed;
      angle = gameRef.joystick.delta.screenAngle();
    } else {
      // Natural deceleration
      velocity *= 0.95;
    }

    position.add(velocity * dt);
    
    // Update body positions for segment following
    bodyPositions.insert(0, position.clone());
    if (bodyPositions.length > currentLength * 10) {
      bodyPositions.removeLast();
    }

    // Micro-animations logic
    _tongueTimer -= dt;
    if (_tongueTimer <= 0) {
      _isTongueOut = !_isTongueOut;
      _tongueTimer = _isTongueOut ? 0.2 : 2.0 + math.Random().nextDouble() * 2.0;
    }

    _blinkTimer -= dt;
    if (_blinkTimer <= 0) {
      _isBlinking = !_isBlinking;
      _blinkTimer = _isBlinking ? 0.1 : 3.0 + math.Random().nextDouble() * 4.0;
    }
    
    // Boundary check
    if (position.x < 0) position.x = 0;
    if (position.y < 0) position.y = 0;
    if (position.x > gameRef.canvasSize.x) position.x = gameRef.canvasSize.x;
    if (position.y > gameRef.canvasSize.y) position.y = gameRef.canvasSize.y;
  }

  @override
  void render(Canvas canvas) {
    final skin = gameRef.gameState.currentSkin;
    // Render Body Segments
    final bodyPaint = Paint()..color = skin.bodyColor;
    for (int i = 1; i < currentLength; i++) {
      int index = i * 8; 
      if (index < bodyPositions.length) {
        Vector2 pos = bodyPositions[index];
        // Coordinates relative to anchor center (0,0)
        double relX = pos.x - position.x;
        double relY = pos.y - position.y;
        
        canvas.drawCircle(
          Offset(relX, relY),
          (size.x / 2.2) * (1 - (i / (currentLength * 2))),
          bodyPaint,
        );
      }
    }

    // Render Tongue
    if (_isTongueOut) {
      final tonguePaint = Paint()..color = Colors.redAccent..strokeWidth = 2;
      canvas.drawLine(Offset(size.x / 2, 0), Offset(size.x / 2 + 10, 0), tonguePaint);
      canvas.drawLine(Offset(size.x / 2 + 10, 0), Offset(size.x / 2 + 14, -4), tonguePaint);
      canvas.drawLine(Offset(size.x / 2 + 10, 0), Offset(size.x / 2 + 14, 4), tonguePaint);
    }

    // Render Head
    final headPaint = Paint()..color = skin.headColor;
    canvas.drawCircle(Offset.zero, size.x / 2, headPaint);
    
    // Eyes
    if (!_isBlinking) {
      final eyePaint = Paint()..color = skin.eyeColor;
      canvas.drawCircle(Offset(size.x * 0.2, -size.x * 0.2), 6, eyePaint);
      canvas.drawCircle(Offset(size.x * 0.2, size.x * 0.2), 6, eyePaint);
      
      final pupilPaint = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(size.x * 0.3, -size.x * 0.2), 2.5, pupilPaint);
      canvas.drawCircle(Offset(size.x * 0.3, size.x * 0.2), 2.5, pupilPaint);
    } else {
      final blinkPaint = Paint()..color = Colors.black45..strokeWidth = 2;
      canvas.drawLine(Offset(size.x * 0.1, -size.x * 0.2), Offset(size.x * 0.3, -size.x * 0.2), blinkPaint);
      canvas.drawLine(Offset(size.x * 0.1, size.x * 0.2), Offset(size.x * 0.3, size.x * 0.2), blinkPaint);
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PreyAnimal) {
      other.removeFromParent();
      gameRef.gameState.addScore(100);
      currentLength = math.min(currentLength + 1, 50);
      
      // Haptic Feedback
      JuiceService.success();
      
      // Floating Score
      gameRef.add(FloatingText('+100', position.clone()));
      
      // Camera Feedback
      gameRef.camera.viewfinder.add(
        MoveEffect.by(
          Vector2(4, 4),
          EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 3),
        ),
      );
      
      // Particles
      gameRef.add(ParticleService.createEatParticle(other.position, gameRef.gameState.currentSkin.headColor));

      add(ScaleEffect.by(Vector2.all(1.2), EffectController(duration: 0.1, reverseDuration: 0.1)));
    }
  }
}
