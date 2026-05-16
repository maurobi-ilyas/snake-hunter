import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'prey_animal.dart';
import 'floating_text.dart';
import '../engine/snake_hunter_game.dart';
import '../../services/juice_service.dart';

class SnakePlayer extends PositionComponent
    with HasGameRef<SnakeHunterGame>, CollisionCallbacks {
  static const double baseSpeed = 180.0;
  static const double biteRadius = 28.0;
  static const double segmentDistance = 12.0;

  /// Desired velocity from joystick input
  Vector2 _targetVelocity = Vector2.zero();
  /// Smoothed, actual velocity for rendering & movement
  Vector2 velocity = Vector2.zero();
  Vector2 _lastDirection = Vector2(1, 0);

  // Trail positions for body following
  final List<Vector2> _trail = [];

  final int initialLength = 4;
  late int currentLength;
  late int _totalSegments;

  // Animation states
  double _tongueTimer = 0;
  bool _isTongueOut = false;
  double _blinkTimer = 0;
  bool _isBlinking = false;
  double _happyTimer = 0;
  double _hungryTimer = 5.0;
  
  // Polish state
  double _squashAmount = 1.0;
  double _stretchAmount = 1.0;
  double _impactTimer = 0;
  double _swayTimer = 0;
  
  // Eating state
  bool _isEating = false;
  double _eatingTimer = 0;
  
  // Head properties
  final double _headSize = 36;
  final double _segmentSize = 20;
  
  // Movement feel
  static const double _turnSmooth = 0.3;
  static const double _accel = 12.0;
  
  bool _loaded = false;

  SnakePlayer() {
    currentLength = initialLength;
    _totalSegments = initialLength * 12;
  }

  @override
  Future<void> onLoad() async {
    size = Vector2.all(_headSize);
    anchor = Anchor.center;
    position = gameRef.size / 2;
    
    // Initialize trail with head position
    for (int i = 0; i < _totalSegments; i++) {
      _trail.add(position.clone());
    }
    
    add(CircleHitbox());
    _loaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_loaded) return;

    // Input handling
    if (!gameRef.joystick.relativeDelta.isZero()) {
      _targetVelocity = gameRef.joystick.relativeDelta * baseSpeed;
    } else {
      _targetVelocity = Vector2.zero();
    }

    // Smooth acceleration/deceleration
    final targetLen = _targetVelocity.length;
    final currentLen = velocity.length;
    
    if (targetLen > 0) {
      final targetVel = _targetVelocity.normalized() * math.min(targetLen, baseSpeed);
      velocity = Vector2(
        _lerp(velocity.x, targetVel.x, dt * _accel),
        _lerp(velocity.y, targetVel.y, dt * _accel),
      );
      _lastDirection = velocity.normalized();
    } else {
      velocity = velocity * (1 - dt * 5);
    }

    // Face direction
    if (velocity.length > 5) {
      angle = velocity.screenAngle();
    }

    // Movement
    position += velocity * dt;

    // World wrap
    final w = gameRef.canvasSize.x;
    final h = gameRef.canvasSize.y;
    if (position.x < 0) position.x = w;
    if (position.x > w) position.x = 0;
    if (position.y < 0) position.y = h;
    if (position.y > h) position.y = 0;

    // Squash & stretch based on speed
    final speedRatio = velocity.length / baseSpeed;
    _stretchAmount = _lerp(_stretchAmount, 1.0 + speedRatio * 0.15, dt * 8);
    _squashAmount = _lerp(_squashAmount, 1.0 - speedRatio * 0.08, dt * 8);
    
    if (_impactTimer > 0) {
      _impactTimer -= dt;
      _stretchAmount = 1.35;
      _squashAmount = 0.7;
    }

    // Timers
    if (_happyTimer > 0) _happyTimer -= dt;
    _hungryTimer -= dt;
    if (_hungryTimer < 0) _hungryTimer = 5.0;
    
    _swayTimer += velocity.length * dt;
    
    if (_isEating) {
      _eatingTimer -= dt;
      if (_eatingTimer <= 0) _isEating = false;
    }

    // Update trail for body follow
    _trail.insert(0, position.clone());
    while (_trail.length > _totalSegments) {
      _trail.removeLast();
    }

    // Micro animations
    _tongueTimer -= dt;
    if (_tongueTimer <= 0) {
      _isTongueOut = !_isTongueOut;
      _tongueTimer = _isTongueOut ? 0.15 : 2.0 + math.Random().nextDouble() * 3.0;
    }

    _blinkTimer -= dt;
    if (_blinkTimer <= 0) {
      _isBlinking = !_isBlinking;
      _blinkTimer = _isBlinking ? 0.12 : 3.0 + math.Random().nextDouble() * 4.0;
    }
  }

  @override
  void render(Canvas canvas) {
    final speedRatio = velocity.length / baseSpeed;
    
    // Render body segments with smooth follow
    for (int i = 1; i < currentLength * 10 && i < _trail.length; i++) {
      if (i * 1 >= _trail.length) break;
      
      final pos = _trail[i * 1];
      final relX = pos.x - position.x;
      const relY = 0.0;
      
      // Wave offset for organic movement
      final waveOffset = math.sin(_swayTimer * 6 + i * 0.5) * 1.5 * speedRatio;
      
      final segRadius = _segmentSize * math.max(0.3, 1.0 - i / (currentLength * 10.0)) * 0.7;
      final segAlpha = 1.0 - (i / (currentLength * 10.0)) * 0.5;

      final bodyPaint = Paint()
        ..color = const Color(0xFF00BCD4).withOpacity(segAlpha * 0.9);

      canvas.drawCircle(Offset(relX + waveOffset, relY), segRadius, bodyPaint);
      
      // Segment highlight
      if (segRadius > 3) {
        final highlightPaint = Paint()
          ..color = const Color(0xFF4DD0E1).withOpacity(segAlpha * 0.5);
        canvas.drawCircle(Offset(relX + waveOffset - 2, relY - 2), segRadius * 0.4, highlightPaint);
      }
    }

    // Tongue
    if (_isTongueOut && !_isEating) {
      final tonguePaint = Paint()
        ..color = const Color(0xFFFF8A80)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      final tipX = _headSize / 2 + 10;
      canvas.drawLine(Offset(_headSize / 2, 0), Offset(tipX, 0), tonguePaint);
      canvas.drawLine(Offset(tipX, 0), Offset(tipX + 5, -4), tonguePaint);
      canvas.drawLine(Offset(tipX, 0), Offset(tipX + 5, 4), tonguePaint);
    }

    // Head
    final headSway = math.sin(_swayTimer * 3) * 0.02 * speedRatio;
    canvas.save();
    canvas.rotate(headSway);
    canvas.scale(_stretchAmount, _squashAmount);

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF48FAD9).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset.zero, _headSize / 2 + 5, glowPaint);

    // Head body
    final headPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        _headSize / 2,
        [const Color(0xFF26C6DA), const Color(0xFF00ACC1)],
      );
    canvas.drawCircle(Offset.zero, _headSize / 2, headPaint);

    // Eyes
    if (!_isBlinking && !_isEating) {
      _renderEyes(canvas, speedRatio);
    } else if (_isBlinking) {
      _renderBlink(canvas);
    } else {
      _renderEatingMouth(canvas);
    }
    
    canvas.restore();
  }

  void _renderEyes(Canvas canvas, double speedRatio) {
    final eyeWhite = Paint()..color = Colors.white;
    final pupil = Paint()..color = Colors.black;
    final highlight = Paint()..color = Colors.white70;

    final pupilX = _lastDirection.x * 3;
    final pupilY = _lastDirection.y * 2;

    // Left eye
    canvas.drawCircle(Offset(_headSize * 0.2, -_headSize * 0.22), 8, eyeWhite);
    canvas.drawCircle(Offset(_headSize * 0.28 + pupilX, -_headSize * 0.22 + pupilY), 3.5, pupil);
    canvas.drawCircle(Offset(_headSize * 0.23 + pupilX, -_headSize * 0.27 + pupilY), 2, highlight);

    // Right eye
    canvas.drawCircle(Offset(_headSize * 0.2, _headSize * 0.22), 8, eyeWhite);
    canvas.drawCircle(Offset(_headSize * 0.28 + pupilX, _headSize * 0.22 + pupilY), 3.5, pupil);
    canvas.drawCircle(Offset(_headSize * 0.23 + pupilX, _headSize * 0.17 + pupilY), 2, highlight);

    // Cheeks when happy
    if (_happyTimer > 0) {
      final blush = Paint()..color = const Color(0xFFFFAB91).withOpacity(0.8);
      canvas.drawCircle(Offset(_headSize * 0.08, -_headSize * 0.12), 3, blush);
      canvas.drawCircle(Offset(_headSize * 0.08, _headSize * 0.12), 3, blush);
    }

    // Expression
    if (_happyTimer > 0 && _happyTimer < 0.3) {
      _renderHappyExpression(canvas);
    } else if (_hungryTimer < 1.5) {
      _renderHungryExpression(canvas);
    } else {
      _renderNeutralExpression(canvas);
    }
  }

  void _renderNeutralExpression(Canvas canvas) {
    final smile = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(_headSize * 0.12, _headSize * 0.12), Offset(_headSize * 0.32, _headSize * 0.12), smile);
  }

  void _renderHappyExpression(Canvas canvas) {
    final smile = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(_headSize * 0.1, _headSize * 0.15), Offset(_headSize * 0.35, _headSize * 0.15), smile);
  }

  void _renderHungryExpression(Canvas canvas) {
    final expression = Paint()
      ..color = const Color(0xFFFF9800)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(_headSize * 0.15, _headSize * 0.15), Offset(_headSize * 0.3, _headSize * 0.15), expression);
    canvas.drawLine(Offset(_headSize * 0.22, _headSize * 0.18), Offset(_headSize * 0.28, _headSize * 0.22), expression);
  }

  void _renderEatingMouth(Canvas canvas) {
    final mouth = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(_headSize * 0.25, _headSize * 0.12), 4, mouth);
  }

  void _renderBlink(Canvas canvas) {
    final blink = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(_headSize * 0.08, -_headSize * 0.22), Offset(_headSize * 0.32, -_headSize * 0.22), blink);
    canvas.drawLine(Offset(_headSize * 0.08, _headSize * 0.22), Offset(_headSize * 0.32, _headSize * 0.22), blink);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PreyAnimal) {
      _eatPrey(other);
    }
  }

  void _eatPrey(PreyAnimal prey) {
    _isEating = true;
    _eatingTimer = 0.25;
    _happyTimer = 0.6;
    _hungryTimer = 5.0;
    
    prey.removeFromParent();
    gameRef.gameState.addScore(100);
    currentLength = math.min(currentLength + 1, 25);
    _totalSegments = currentLength * 12;
    
    JuiceService.success();
    
    // Slow motion eating effect
    gameRef.timeScale = 0.7;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (gameRef.timeScale < 1.0) gameRef.timeScale = 1.0;
    });
    
    gameRef.add(FloatingText('+100', position.clone()));

    // Camera effects
    gameRef.camera.viewfinder.add(
      MoveEffect.by(
        Vector2(8, 8),
        EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 2),
      ),
    );

    gameRef.add(
      gameRef.particlePool.get(
        prey.position,
        const Color(0xFF00BCD4),
      ),
    );

    add(ScaleEffect.by(
      Vector2.all(1.2),
      EffectController(duration: 0.1, reverseDuration: 0.15),
    ));
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0, 1);
}