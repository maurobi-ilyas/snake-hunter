import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../engine/snake_hunter_game.dart';

enum AIState { idle, wandering, escaping, eaten, taunting }

enum AnimalType { mouse, rabbit, frog, bird, chick }

class PreyAnimal extends PositionComponent with HasGameRef<SnakeHunterGame>, CollisionCallbacks {
  final AnimalType type;
  final double speed;
  
  AIState state = AIState.wandering;
  Vector2 velocity = Vector2.zero();
  double _stateTimer = 0;
  final math.Random _random = math.Random();
  
  // Animation
  double _panicTimer = 0;
  double _bounceTimer = 0;
  double _tauntTimer = 0;
  bool _hasEscaped = false;
  
  // Personality traits
  final double _panicDuration;
  final double _escapeBoost;
  final Color _color;
  final String _emoji;
  
  static const Map<AnimalType, Map<String, dynamic>> _traits = {
    AnimalType.mouse: {
      'speed': 90.0, 'panic': 1.2, 'boost': 2.0, 
      'color': 0xFFA1887F, 'emoji': '🐭', 'zigZag': true
    },
    AnimalType.rabbit: {
      'speed': 130.0, 'panic': 0.9, 'boost': 2.3,
      'color': 0xFFE0E0E0, 'emoji': '🐰', 'hop': true
    },
    AnimalType.frog: {
      'speed': 100.0, 'panic': 1.5, 'boost': 1.8,
      'color': 0xFF9CCC65, 'emoji': '🐸', 'randomJump': true
    },
    AnimalType.bird: {
      'speed': 160.0, 'panic': 0.7, 'boost': 2.5,
      'color': 0xFFB3E5FC, 'emoji': '🐦', 'quickTurn': true
    },
    AnimalType.chick: {
      'speed': 110.0, 'panic': 1.0, 'boost': 2.1,
      'color': 0xFFFFF9C4, 'emoji': '🐥', 'scatter': true
    },
  };
  
  PreyAnimal({required this.type, double? speed}) 
      : speed = speed ?? _traits[type]!['speed'],
        _panicDuration = _traits[type]!['panic'],
        _escapeBoost = _traits[type]!['boost'],
        _color = Color(_traits[type]!['color']),
        _emoji = _traits[type]!['emoji'],
        super(size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    _resetWander();
  }
  
  void _resetWander() {
    final angle = _random.nextDouble() * math.pi * 2;
    velocity = Vector2(math.cos(angle), math.sin(angle)) * speed * 0.4;
    _stateTimer = 2 + _random.nextDouble() * 2;
    _hasEscaped = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state == AIState.eaten) return;

    _panicTimer += dt;
    _bounceTimer += dt * 10;

    final distanceToSnake = position.distanceTo(gameRef.snake.position);
    
    if (distanceToSnake < 200 || _stateTimer <= 0) {
      _updateAI(dt, distanceToSnake);
    }
    
    position += velocity * dt;

    // Boundary wrap
    final w = gameRef.canvasSize.x;
    final h = gameRef.canvasSize.y;
    if (position.x < 0) position.x = w;
    if (position.x > w) position.x = 0;
    if (position.y < 0) position.y = h;
    if (position.y > h) position.y = 0;
  }

  void _updateAI(double dt, double distanceToSnake) {
    _stateTimer -= dt;
    const biteRadius = 25.0;
    
    // Detection and escape logic
    if (distanceToSnake < 90 && state != AIState.escaping) {
      state = AIState.escaping;
      _stateTimer = _panicDuration;
      _panicTimer = 0;
    } else if (distanceToSnake > biteRadius && state == AIState.escaping && !_hasEscaped) {
      _hasEscaped = true;
      state = AIState.taunting;
      _tauntTimer = 0.8;
    } else if (state == AIState.taunting && _tauntTimer > 0) {
      _tauntTimer -= dt;
      if (_tauntTimer <= 0) {
        state = AIState.wandering;
        _resetWander();
      }
    } else if (state == AIState.escaping && _stateTimer <= 0) {
      state = AIState.wandering;
      _resetWander();
    }

    // Movement based on state
    switch (state) {
      case AIState.wandering:
        if (_stateTimer <= 0) _resetWander();
        break;
      case AIState.escaping:
        _escapeMovement(distanceToSnake);
        break;
      case AIState.taunting:
        velocity *= 0.92;
        break;
      default:
        break;
    }
  }

  void _escapeMovement(double distanceToSnake) {
    final dir = (position - gameRef.snake.position).normalized();
    velocity = dir * speed * _escapeBoost;
    
    // Personality-based movement
    final traits = _traits[type]!;
    if (traits['zigZag'] == true) {
      velocity.x += math.sin(_bounceTimer * 15) * 20;
    }
    if (traits['hop'] == true) {
      velocity.y += math.sin(_bounceTimer * 12) * 15;
    }
  }

  @override
  void render(Canvas canvas) {
    final bounce = switch(state) {
      AIState.escaping => math.sin(_bounceTimer) * 4.0,
      AIState.taunting => math.sin(_bounceTimer) * 2.0,
      _ => 0.0
    };
    
    canvas.save();
    
    // Translate to center for drawing (since face offsets assume 0,0 is center)
    canvas.translate(size.x / 2, size.y / 2 + bounce);
    
    if (state == AIState.escaping) {
      final scale = 1.0 + math.sin(_panicTimer * 15) * 0.08;
      canvas.scale(scale);
    }
    
    // Draw body
    final bodyPaint = Paint()..color = _color;
    canvas.drawCircle(Offset.zero, 14, bodyPaint);
    
    super.render(canvas);
    
    // Expressions
    if (state == AIState.escaping) {
      _renderScaredFace(canvas);
    } else if (state == AIState.taunting) {
      _renderTauntFace(canvas);
    } else {
      // Normal face
      final black = Paint()..color = Colors.black;
      canvas.drawCircle(Offset(-4, -2), 2, black);
      canvas.drawCircle(Offset(4, -2), 2, black);
    }
    
    canvas.restore();
  }

  void _renderScaredFace(Canvas canvas) {
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;
    
    // Wide eyes
    canvas.drawCircle(Offset(-6, -4), 5, white);
    canvas.drawCircle(Offset(6, -4), 5, white);
    canvas.drawCircle(Offset(-6, -4), 2.5, black);
    canvas.drawCircle(Offset(6, -4), 2.5, black);
    
    // O mouth
    canvas.drawCircle(Offset(0, 5), 3, black);
  }

  void _renderTauntFace(Canvas canvas) {
    final black = Paint()..color = Colors.black;
    final pink = Paint()..color = const Color(0xFFFF8A80);
    
    // Wink + tongue
    canvas.drawLine(Offset(-10, -4), Offset(2, -4), black..strokeWidth = 2);
    canvas.drawCircle(Offset(10, 4), 3, black);
    
    final tongue = Paint()
      ..color = const Color(0xFFFF8A80)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 8), Offset(8, 12), tongue);
  }

  void onEaten() {
    state = AIState.eaten;
    removeFromParent();
  }
}