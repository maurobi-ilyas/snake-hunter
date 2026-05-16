import 'package:flutter/material.dart';

import '../models/position_model.dart';

class SnakeComponent {
  late List<PositionModel> body;
  Color snakeColor = Colors.greenAccent;

  SnakeComponent() {
    body = [
      PositionModel(x: 5, y: 10),
      PositionModel(x: 4, y: 10),
      PositionModel(x: 3, y: 10),
    ];
  }
}
