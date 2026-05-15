import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class FloatingText extends TextComponent with HasGameRef {
  FloatingText(String text, Vector2 position) : super(
    text: text,
    position: position,
    anchor: Anchor.center,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(2, 2))],
      ),
    ),
  );

  @override
  Future<void> onLoad() async {
    add(MoveByEffect(
      Vector2(0, -50),
      EffectController(duration: 0.8, curve: Curves.easeOut),
    ));
    add(OpacityEffect.fadeOut(
      EffectController(duration: 0.8, curve: Curves.easeIn),
      onComplete: removeFromParent,
    ));
  }
}
