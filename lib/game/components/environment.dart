import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class Environment extends Component with HasGameRef {
  final List<_GrassBlade> _grassBlades = [];
  final List<Offset> _bushPositions = [];
  final List<double> _bushScales = [];
  final math.Random _random = math.Random();

  // Static cached background (no repaint)
  ui.Picture? _cachedBackground;

  // Animated grass (live blades)
  double _windTimer = 0;

  @override
  Future<void> onLoad() async {
    final w = gameRef.canvasSize.x;
    final h = gameRef.canvasSize.y;

    // Grass blades
    for (int i = 0; i < 80; i++) {
      _grassBlades.add(_GrassBlade(
        position: Offset(_random.nextDouble() * w, _random.nextDouble() * h),
        height: 8 + _random.nextDouble() * 8,
        phase: _random.nextDouble() * math.pi * 2,
      ));
    }

    // Bushes (static cached)
    for (int i = 0; i < 18; i++) {
      _bushPositions.add(Offset(
        _random.nextDouble() * w,
        _random.nextDouble() * h,
      ));
      _bushScales.add(0.8 + _random.nextDouble() * 0.5);
    }

    _cachePicture();
  }

  void _cachePicture() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = gameRef.canvasSize.x;
    final h = gameRef.canvasSize.y;

    // — Background gradient (top-light, bottom-darker) —
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(w / 2, 0),
        Offset(w / 2, h),
        [const Color(0xFFEAF6EA), const Color(0xFFD0ECCD)],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // — Grid dots (subtle) —
    final dotPaint = Paint()..color = const Color(0x22228B22);
    const spacing = 48.0;
    for (double x = spacing; x < w; x += spacing) {
      for (double y = spacing; y < h; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }

    // — Border frame —
    final borderPaint = Paint()
      ..color = const Color(0x66388E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, w - 8, h - 8),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // — Bushes —
    for (int i = 0; i < _bushPositions.length; i++) {
      final pos = _bushPositions[i];
      final sc = _bushScales[i];
      final shadow = Paint()..color = const Color(0x22000000);
      canvas.drawOval(
        Rect.fromCenter(center: pos + Offset(4 * sc, 8 * sc), width: 30 * sc, height: 10 * sc),
        shadow,
      );
      final bushDark = Paint()..color = const Color(0xFF81C784);
      final bushLight = Paint()..color = const Color(0xFFA5D6A7);
      canvas.drawCircle(pos, 14 * sc, bushDark);
      canvas.drawCircle(pos + Offset(10 * sc, 4 * sc), 11 * sc, bushDark);
      canvas.drawCircle(pos + Offset(-10 * sc, 4 * sc), 11 * sc, bushDark);
      canvas.drawCircle(pos + Offset(0, -4 * sc), 10 * sc, bushLight);
    }

    _cachedBackground = recorder.endRecording();
  }

  @override
  void update(double dt) {
    _windTimer += dt * 1.2;
  }

  @override
  void render(Canvas canvas) {
    // Draw static cached background first
    if (_cachedBackground != null) {
      canvas.drawPicture(_cachedBackground!);
    }

    // Draw animated grass blades on top
    final grassPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (final blade in _grassBlades) {
      final sway = math.sin(_windTimer + blade.phase) * 3.0;
      final color = Color.lerp(
        const Color(0xFF66BB6A),
        const Color(0xFF43A047),
        (math.sin(blade.phase) + 1) / 2,
      )!;
      grassPaint.color = color.withOpacity(0.7);

      final base = blade.position;
      final tip = blade.position + Offset(sway, -blade.height);
      canvas.drawLine(base, tip, grassPaint);

      // Second shorter blade
      final tip2 = blade.position + Offset(-sway * 0.6 + 3, -blade.height * 0.7);
      grassPaint.color = color.withOpacity(0.5);
      canvas.drawLine(base + const Offset(4, 0), tip2, grassPaint);
    }
  }

  @override
  void onRemove() {
    _cachedBackground?.dispose();
    super.onRemove();
  }
}

class _GrassBlade {
  final Offset position;
  final double height;
  final double phase;
  const _GrassBlade({required this.position, required this.height, required this.phase});
}
