import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'particle_service.dart';
import 'dart:collection';

class ParticlePool {
  final Queue<Component> _pool = Queue();
  static const int maxPoolSize = 20;

  Component get(Vector2 position, Color color) {
    if (_pool.isNotEmpty) {
      final comp = _pool.removeFirst();
      if (comp is ParticleSystemComponent) {
        comp.particle = ParticleService.getEatParticle(position, color);
        return comp;
      }
    }
    return ParticleService.createEatParticle(position, color);
  }

  void release(Component component) {
    if (_pool.length < maxPoolSize) {
      _pool.add(component);
    }
  }
}
