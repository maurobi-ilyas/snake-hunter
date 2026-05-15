import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'juice_service.dart';

class ParticleService {
  static Component createEatParticle(Vector2 position, Color color) {
    final count = (15 * JuiceService.particleCountMultiplier).toInt();
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: count,
        lifespan: 0.8,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 100),
          speed: Vector2.random() * 200 - Vector2.all(100),
          position: position.clone(),
          child: CircleParticle(
            radius: 2.0 + (i % 3),
            paint: Paint()..color = color.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
