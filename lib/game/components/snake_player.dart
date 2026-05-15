import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'prey_animal.dart';
import 'floating_text.dart';
import '../engine/snake_hunter_game.dart';
import '../../services/juice_service.dart';

class SnakePlayer extends PositionComponent
    with HasGameRef<SnakeHunterGame>, CollisionCallbacks {
  static const double baseSpeed = 220.0;

  /// Desired velocity from joystick input
  Vector2 _targetVelocity = Vector2.zero();
  /// Smoothed, actual velocity for rendering & movement
  Vector2 velocity = Vector2.zero();

  final List<Vector2> bodyPositions = [];
  final int initialLength = 5;
  late int currentLength;

  // Micro-animation timers
  double _tongueTimer = 0;
  bool _isTongueOut = false;
  double _blinkTimer = 0;
  bool _isBlinking = false;

  // AAA Polish state
  double _squashAmount = 1.0;
  double _stretchAmount = 1.0;
  double _impactTimer = 0;

  // Sway animation
  double _swayTimer = 0;
  static const double _swayFreq = 4.0;
  static const double _swayAmp = 0.04; // radians

  // Spawn-safe flag
  bool _loaded = false;

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
    _loaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_loaded) return;

    // ── Input ──────────────────────────────────────────────────────────────
    if (!gameRef.joystick.relativeDelta.isZero()) {
      _targetVelocity = gameRef.joystick.relativeDelta * baseSpeed;
    } else {
      _targetVelocity = Vector2.zero();
    }

    // Smooth velocity interpolation (lerp) — eliminates kaku feeling
    velocity = Vector2(
      _lerp(velocity.x, _targetVelocity.x, dt * 8),
      _lerp(velocity.y, _targetVelocity.y, dt * 8),
    );

    // Stop very small drift
    if (velocity.length < 2) velocity = Vector2.zero();

    // Face direction of travel
    if (velocity.length > 10) {
      angle = velocity.screenAngle();
    }

    // ── Movement ────────────────────────────────────────────────────────────
    position.add(velocity * dt);

    // ── WORLD WRAP (critical bug fix) ───────────────────────────────────────
    final w = gameRef.canvasSize.x;
    final h = gameRef.canvasSize.y;
    if (position.x < 0)  position.x = w;
    if (position.x > w)  position.x = 0;
    if (position.y < 0)  position.y = h;
    if (position.y > h)  position.y = 0;

    // ── Squash & Stretch ────────────────────────────────────────────────────
    final speedRatio = velocity.length / baseSpeed;
    _stretchAmount = _lerp(_stretchAmount, 1.0 + speedRatio * 0.12, dt * 10);
    _squashAmount  = _lerp(_squashAmount,  1.0 - speedRatio * 0.06, dt * 10);

    if (_impactTimer > 0) {
      _impactTimer -= dt;
      _stretchAmount = 1.3;
      _squashAmount  = 0.75;
    }

    // ── Sway animation ──────────────────────────────────────────────────────
    if (velocity.length > 10) {
      _swayTimer += dt;
    }

    // ── Body trail ──────────────────────────────────────────────────────────
    bodyPositions.insert(0, position.clone());
    if (bodyPositions.length > currentLength * 10) {
      bodyPositions.removeLast();
    }

    // ── Micro-animations ────────────────────────────────────────────────────
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
  }

  @override
  void render(Canvas canvas) {
    final skin = gameRef.gameState.currentSkin;

    // ── Body segments ───────────────────────────────────────────────────────
    for (int i = currentLength - 1; i >= 1; i--) {
      final index = i * 8;
      if (index >= bodyPositions.length) continue;

      final pos = bodyPositions[index];
      final relX = pos.x - position.x;
      final relY = pos.y - position.y;
      final segRadius = (size.x / 2.2) * (1 - (i / (currentLength * 2.0)));
      final segAlpha = 1.0 - (i / (currentLength + 1.0)) * 0.4;

      final bodyPaint = Paint()
        ..color = skin.bodyColor.withOpacity(segAlpha);

      canvas.drawCircle(Offset(relX, relY), segRadius.clamp(4, 20), bodyPaint);
    }

    // ── Tongue ──────────────────────────────────────────────────────────────
    if (_isTongueOut) {
      final tonguePaint = Paint()
        ..color = Colors.redAccent
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final tipX = size.x / 2 + 10;
      canvas.drawLine(Offset(size.x / 2, 0), Offset(tipX, 0), tonguePaint);
      canvas.drawLine(Offset(tipX, 0), Offset(tipX + 5, -4), tonguePaint);
      canvas.drawLine(Offset(tipX, 0), Offset(tipX + 5, 4), tonguePaint);
    }

    // ── Head (with sway + squash/stretch) ───────────────────────────────────
    final sway = math.sin(_swayTimer * _swayFreq) * _swayAmp;
    canvas.save();
    canvas.rotate(sway);
    canvas.scale(_stretchAmount, _squashAmount);

    // Head glow
    final glowPaint = Paint()
      ..color = skin.headColor.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset.zero, size.x / 2 + 4, glowPaint);

    // Head fill
    final headPaint = Paint()..color = skin.headColor;
    canvas.drawCircle(Offset.zero, size.x / 2, headPaint);

    // Eyes
    if (!_isBlinking) {
      final eyeWhitePaint = Paint()..color = Colors.white;
      final eyePaint = Paint()..color = skin.eyeColor;
      final pupilPaint = Paint()..color = Colors.black;

      canvas.drawCircle(Offset(size.x * 0.2, -size.x * 0.22), 7, eyeWhitePaint);
      canvas.drawCircle(Offset(size.x * 0.2,  size.x * 0.22), 7, eyeWhitePaint);
      canvas.drawCircle(Offset(size.x * 0.2, -size.x * 0.22), 5, eyePaint);
      canvas.drawCircle(Offset(size.x * 0.2,  size.x * 0.22), 5, eyePaint);
      canvas.drawCircle(Offset(size.x * 0.28, -size.x * 0.22), 2, pupilPaint);
      canvas.drawCircle(Offset(size.x * 0.28,  size.x * 0.22), 2, pupilPaint);
    } else {
      final blinkPaint = Paint()
        ..color = Colors.black54
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(size.x * 0.12, -size.x * 0.22),
        Offset(size.x * 0.3, -size.x * 0.22),
        blinkPaint,
      );
      canvas.drawLine(
        Offset(size.x * 0.12, size.x * 0.22),
        Offset(size.x * 0.3,  size.x * 0.22),
        blinkPaint,
      );
    }

    canvas.restore();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PreyAnimal) {
      other.removeFromParent();
      gameRef.gameState.addScore(100);
      currentLength = math.min(currentLength + 1, 50);
      _impactTimer = 0.2;

      JuiceService.success();
      gameRef.add(FloatingText('+100', position.clone()));

      // Camera shake
      gameRef.camera.viewfinder.add(
        MoveEffect.by(
          Vector2(5, 5),
          EffectController(duration: 0.04, reverseDuration: 0.04, repeatCount: 3),
        ),
      );

      // Pooled particle burst
      gameRef.add(
        gameRef.particlePool.get(
          other.position,
          gameRef.gameState.currentSkin.headColor,
        ),
      );

      add(ScaleEffect.by(
        Vector2.all(1.25),
        EffectController(duration: 0.08, reverseDuration: 0.12),
      ));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0, 1);
}
