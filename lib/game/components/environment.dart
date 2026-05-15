import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Environment extends Component with HasGameRef {
  final List<Offset> _grassPositions = [];
  final List<Offset> _bushPositions = [];
  final math.Random _random = math.Random();

  @override
  Future<void> onLoad() async {
    // Generate some random decorations
    for (int i = 0; i < 50; i++) {
      _grassPositions.add(Offset(
        _random.nextDouble() * gameRef.canvasSize.x,
        _random.nextDouble() * gameRef.canvasSize.y,
      ));
    }
    for (int i = 0; i < 15; i++) {
      _bushPositions.add(Offset(
        _random.nextDouble() * gameRef.canvasSize.x,
        _random.nextDouble() * gameRef.canvasSize.y,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw background
    final paint = Paint()
      ..color = const Color(0xFFE8F5E9)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(gameRef.canvasSize.toRect(), paint);
    
    // Draw Grass (Simple V shape)
    final grassPaint = Paint()
      ..color = const Color(0xFFC8E6C9)
      ..strokeWidth = 2;
    
    for (final pos in _grassPositions) {
      canvas.drawLine(pos, pos + const Offset(-5, -10), grassPaint);
      canvas.drawLine(pos, pos + const Offset(5, -10), grassPaint);
    }
    
    // Draw Bushes (Simple clouds)
    final bushPaint = Paint()..color = const Color(0xFFA5D6A7);
    for (final pos in _bushPositions) {
      canvas.drawCircle(pos, 15, bushPaint);
      canvas.drawCircle(pos + const Offset(10, 5), 12, bushPaint);
      canvas.drawCircle(pos + const Offset(-10, 5), 12, bushPaint);
    }
  }
}
