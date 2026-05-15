import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Floating score popup — manual opacity fade, no OpacityEffect (avoids provider crash)
class FloatingText extends PositionComponent with HasGameRef {
  final String _text;
  double _life = 0.85; // seconds
  double _elapsed = 0;

  FloatingText(this._text, Vector2 pos)
      : super(position: pos, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _life) {
      removeFromParent();
      return;
    }
    // Float upward
    position.y -= 55 * dt;
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / _life).clamp(0.0, 1.0);
    // Fade out after 40% of lifetime
    final alpha = progress < 0.4 ? 1.0 : (1.0 - ((progress - 0.4) / 0.6)).clamp(0.0, 1.0);
    // Scale up then hold
    final scale = progress < 0.15 ? (progress / 0.15) * 1.2 : 1.0;

    final style = TextStyle(
      color: Colors.white.withOpacity(alpha),
      fontSize: 22 * scale,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          blurRadius: 6,
          color: Colors.orange.withOpacity(alpha * 0.8),
          offset: const Offset(0, 2),
        ),
      ],
    );

    final painter = TextPainter(
      text: TextSpan(text: _text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  }
}
