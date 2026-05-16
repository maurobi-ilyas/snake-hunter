import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// Premium AAA Environment — X10THINK Visual Identity Redesign
/// Vibrant pastel palette, layered depth, atmospheric particles
class Environment extends Component with HasGameRef {
  // Static decoration data
  final List<_Flower> _flowers = [];
  final List<_Rock> _rocks = [];
  final List<_Mushroom> _mushrooms = [];
  final List<_Bush> _bushes = [];
  final List<_GrassBlade> _grassBlades = [];
  final List<_FloatingLeaf> _floatingLeaves = [];

  // Cached static layer (background + decorations)
  ui.Picture? _cachedBackground;

  // Wind animation
  double _windTimer = 0;
  double _leafTimer = 0;

  final math.Random _rng = math.Random(42); // Fixed seed = deterministic layout

  @override
  Future<void> onLoad() async {
    final w = gameRef.canvasSize.x;
    final h = gameRef.canvasSize.y;

    // Generate vibrant decorative elements
    for (int i = 0; i < 45; i++) {
      _flowers.add(_Flower(
        pos: Offset(_rng.nextDouble() * w, _rng.nextDouble() * h),
        color: [
          const Color(0xFFFF8A80), // Soft Red
          const Color(0xFFFFF176), // Soft Yellow
          const Color(0xFFF48FB1), // Soft Pink
          const Color(0xFFCE93D8), // Soft Purple
          const Color(0xFFB39DDB), // Soft Violet
        ][_rng.nextInt(5)],
        petalColor: [
          const Color(0xFFFFCCD5),
          const Color(0xFFFFFFB2),
          const Color(0xFFFAD4D9),
          const Color(0xFFE1BEE7),
        ][_rng.nextInt(4)],
        radius: 5 + _rng.nextDouble() * 4,
      ));
    }

    for (int i = 0; i < 10; i++) {
      _rocks.add(_Rock(
        pos: Offset(_rng.nextDouble() * w, _rng.nextDouble() * h),
        size: 22 + _rng.nextDouble() * 22,
      ));
    }

    for (int i = 0; i < 12; i++) {
      _mushrooms.add(_Mushroom(
        pos: Offset(_rng.nextDouble() * w, _rng.nextDouble() * h),
        scale: 0.8 + _rng.nextDouble() * 0.5,
      ));
    }

    for (int i = 0; i < 16; i++) {
      _bushes.add(_Bush(
        pos: Offset(_rng.nextDouble() * w, _rng.nextDouble() * h),
        scale: 0.9 + _rng.nextDouble() * 0.6,
      ));
    }

    for (int i = 0; i < 140; i++) {
      _grassBlades.add(_GrassBlade(
        pos: Offset(_rng.nextDouble() * w, _rng.nextDouble() * h),
        height: 10 + _rng.nextDouble() * 12,
        phase: _rng.nextDouble() * math.pi * 2,
      ));
    }

    _cacheBackground();
  }

  void _cacheBackground() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final w = gameRef.canvasSize.x;
    final h = gameRef.canvasSize.y;

    // ── Sky gradient with pastel tones ──────────────────────────────────
    final bgShader = ui.Gradient.linear(
      Offset(w / 2, 0),
      Offset(w / 2, h),
      [const Color(0xFFC5E1A5), const Color(0xFF81C784), const Color(0xFF66BB6A)],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = bgShader);

    // ── Subtle texture dots ─────────────────────────────────────────────
    final dotPaint = Paint()
      ..color = const Color(0x11FFFFFF)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 80; i++) {
      final x = _rng.nextDouble() * w;
      final y = _rng.nextDouble() * h;
      final size = 2 + _rng.nextDouble() * 4;
      canvas.drawCircle(Offset(x, y), size, dotPaint);
    }

    // ── Floating decorative bubbles (background layer) ─────────────────
    for (int i = 0; i < 20; i++) {
      final cx = _rng.nextDouble() * w;
      final cy = _rng.nextDouble() * h;
      final radius = 8 + _rng.nextDouble() * 12;
      canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()..color = const Color(0x11FFFFFF),
      );
    }

    // ── Dirt path (organic curved stripe) ───────────────────────────────
    final pathPaint = Paint()..color = const Color(0x33A1887F);
    canvas.drawRect(Rect.fromLTWH(-20, h * 0.3, w + 40, 70), pathPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.32, -20, 70, h + 40), pathPaint);

    // ── Rocks ───────────────────────────────────────────────────
    for (final rock in _rocks) {
      _drawRock(canvas, rock);
    }

    // ── Mushrooms ────────────────────────────────────────────────
    for (final m in _mushrooms) {
      _drawMushroom(canvas, m);
    }

    // ── Bushes ───────────────────────────────────────────────────
    for (final b in _bushes) {
      _drawBush(canvas, b);
    }

    // ── Flowers ──────────────────────────────────────────────────
    for (final f in _flowers) {
      _drawFlower(canvas, f);
    }

    // ── World border ─────────────────────────────────────────────
    final borderPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(w, h),
        [const Color(0x884CAF50), const Color(0x882ECC71)],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2.5, 2.5, w - 5, h - 5),
        const Radius.circular(0),
      ),
      borderPaint,
    );

    _cachedBackground = recorder.endRecording();
  }

  void _drawRock(Canvas c, _Rock rock) {
    // Shadow
    c.drawOval(
      Rect.fromCenter(center: rock.pos + Offset(rock.size * 0.15, rock.size * 0.25), width: rock.size * 1.2, height: rock.size * 0.4),
      Paint()..color = const Color(0x33000000),
    );
    // Rock body
    final bodyPath = Path()
      ..addOval(Rect.fromCenter(center: rock.pos, width: rock.size, height: rock.size * 0.72));
    c.drawPath(bodyPath, Paint()..color = const Color(0xFFB0BEC5));
    // Highlight
    c.drawOval(
      Rect.fromCenter(center: rock.pos + Offset(-rock.size * 0.12, -rock.size * 0.12), width: rock.size * 0.45, height: rock.size * 0.28),
      Paint()..color = const Color(0x55FFFFFF),
    );
    // Dark edge
    c.drawPath(bodyPath, Paint()
      ..color = const Color(0xFF78909C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  void _drawMushroom(Canvas c, _Mushroom m) {
    final s = m.scale;
    final p = m.pos;
    // Shadow
    c.drawOval(Rect.fromCenter(center: p + Offset(0, 14 * s), width: 22 * s, height: 7 * s), Paint()..color = const Color(0x33000000));
    // Stem
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p + Offset(0, 7 * s), width: 9 * s, height: 14 * s), Radius.circular(4 * s)), Paint()..color = const Color(0xFFFFF9C4));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p + Offset(0, 7 * s), width: 9 * s, height: 14 * s), Radius.circular(4 * s)), Paint()..color = const Color(0x44D4AC30)..style = PaintingStyle.stroke..strokeWidth = 1);
    // Cap - vibrant red
    final capPath = Path()
      ..moveTo(p.dx - 13 * s, p.dy)
      ..quadraticBezierTo(p.dx, p.dy - 20 * s, p.dx + 13 * s, p.dy)
      ..close();
    c.drawPath(capPath, Paint()..color = const Color(0xFFFF8A80));
    // White dots
    for (final dot in [Offset(-5 * s, -5 * s), Offset(4 * s, -8 * s), Offset(0, -2 * s)]) {
      c.drawCircle(p + dot, 2.5 * s, Paint()..color = const Color(0xDDFFFFFF));
    }
  }

  void _drawBush(Canvas c, _Bush b) {
    final s = b.scale;
    final p = b.pos;
    c.drawOval(Rect.fromCenter(center: p + Offset(4 * s, 12 * s), width: 34 * s, height: 10 * s), Paint()..color = const Color(0x33000000));
    final layers = [
      [const Color(0xFF33691E), Offset(-11 * s, 4 * s), 12.0 * s],
      [const Color(0xFF33691E), Offset(11 * s, 4 * s), 12.0 * s],
      [const Color(0xFF388E3C), Offset(0, 0 * s),       14.0 * s],
      [const Color(0xFF43A047), Offset(0, -5 * s),      10.0 * s],
    ];
    for (final l in layers) {
      c.drawCircle(p + (l[1] as Offset), l[2] as double, Paint()..color = l[0] as Color);
    }
  }

  void _drawFlower(Canvas c, _Flower f) {
    // Petal glow
    final glowPaint = Paint()..color = f.color.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    c.drawCircle(f.pos, f.radius + 3, glowPaint);
    // Petals
    final petalPaint = Paint()..color = f.color;
    for (int i = 0; i < 6; i++) {
      final angle = math.pi / 3 * i;
      c.drawCircle(f.pos + Offset(math.cos(angle) * f.radius * 0.9, math.sin(angle) * f.radius * 0.9), f.radius * 0.55, petalPaint);
    }
    // Center
    c.drawCircle(f.pos, f.radius * 0.42, Paint()..color = const Color(0xFFFFEB3B));
  }

  @override
  void update(double dt) {
    _windTimer += dt * 1.5;
    _leafTimer += dt;
    if (_leafTimer > 3 + _rng.nextDouble() * 2) {
      _floatingLeaves.add(_FloatingLeaf(
        pos: Offset(_rng.nextDouble() * gameRef.canvasSize.x, gameRef.canvasSize.y + 20),
        phase: _rng.nextDouble() * math.pi * 2,
      ));
      _leafTimer = 0;
    }
    if (_floatingLeaves.length > 15) {
      _floatingLeaves.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_cachedBackground != null) {
      canvas.drawPicture(_cachedBackground!);
    }
    // Animated grass
    final grassPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (final blade in _grassBlades) {
      final sway = math.sin(_windTimer + blade.phase) * 4;
      final brightness = (math.sin(blade.phase) + 1) / 2;
      grassPaint.color = Color.lerp(const Color(0xFF33691E), const Color(0xFF76FF03), brightness * 0.6)!.withOpacity(0.8);
      canvas.drawLine(blade.pos, blade.pos + Offset(sway, -blade.height), grassPaint);
    }

    // Floating leaves (atmospheric particles)
    final leafPaint = Paint()..color = const Color(0x88FFFFFF);
    for (final leaf in _floatingLeaves) {
      leaf.update(0.016);
      canvas.drawCircle(leaf.pos, 6, leafPaint);
    }
  }

  @override
  void onRemove() {
    _cachedBackground?.dispose();
    super.onRemove();
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _Flower {
  final Offset pos;
  final Color color;
  final Color petalColor;
  final double radius;
  const _Flower({required this.pos, required this.color, required this.petalColor, required this.radius});
}

class _Rock {
  final Offset pos;
  final double size;
  const _Rock({required this.pos, required this.size});
}

class _Mushroom {
  final Offset pos;
  final double scale;
  const _Mushroom({required this.pos, required this.scale});
}

class _Bush {
  final Offset pos;
  final double scale;
  const _Bush({required this.pos, required this.scale});
}

class _GrassBlade {
  final Offset pos;
  final double height;
  final double phase;
  const _GrassBlade({required this.pos, required this.height, required this.phase});
}

class _FloatingLeaf {
  Offset pos;
  final double phase;
  double speed = 15;
  
  _FloatingLeaf({required this.pos, required this.phase});
  
  void update(double dt) {
    pos = Offset(pos.dx - speed * dt, pos.dy - speed * 0.5 * dt);
    speed *= 0.995;
  }
}