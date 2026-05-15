import 'package:flutter/material.dart';

class SnakeSkin {
  final String id;
  final String name;
  final Color headColor;
  final Color bodyColor;
  final Color eyeColor;
  final double scale;

  const SnakeSkin({
    required this.id,
    required this.name,
    required this.headColor,
    required this.bodyColor,
    this.eyeColor = Colors.white,
    this.scale = 1.0,
  });

  static const defaultSkin = SnakeSkin(
    id: 'default',
    name: 'Greenie',
    headColor: Color(0xFF66BB6A),
    bodyColor: Color(0xFF81C784),
  );

  static const neonSkin = SnakeSkin(
    id: 'neon',
    name: 'Neon Racer',
    headColor: Color(0xFF00E5FF),
    bodyColor: Color(0xFF18FFFF),
    eyeColor: Colors.yellow,
  );
}
