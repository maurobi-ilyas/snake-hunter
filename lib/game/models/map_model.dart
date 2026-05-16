import 'package:flutter/material.dart';

class MapModel {
  final String name;
  final Color backgroundColor;
  final Color gridColor;
  final Color accentColor;
  final String description;

  const MapModel({
    required this.name,
    required this.backgroundColor,
    required this.gridColor,
    required this.accentColor,
    required this.description,
  });
}
