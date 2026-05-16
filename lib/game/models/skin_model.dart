import 'package:flutter/material.dart';

class SkinModel {
  final String id;
  final String name;
  final int price;
  bool owned;
  final Color color;
  final Color glowColor;

  SkinModel({
    required this.id,
    required this.name,
    required this.price,
    required this.owned,
    required this.color,
    Color? glowColor,
  }) : glowColor = glowColor ?? color;
}
