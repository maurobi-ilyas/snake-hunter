import 'package:flutter/material.dart';

import '../models/map_model.dart';

const List<MapModel> gameMaps = [
  MapModel(
    name: 'Neon City',
    backgroundColor: Color(0xFF050816),
    gridColor: Colors.greenAccent,
    accentColor: Colors.greenAccent,
    description: 'Stage 1 — Welcome to the neon streets.',
  ),
  MapModel(
    name: 'Cyber Tunnel',
    backgroundColor: Color(0xFF040D1F),
    gridColor: Colors.blueAccent,
    accentColor: Colors.blueAccent,
    description: 'Stage 2 — Deep inside the data stream.',
  ),
  MapModel(
    name: 'Dark Lab',
    backgroundColor: Color(0xFF0D0617),
    gridColor: Colors.purpleAccent,
    accentColor: Colors.purpleAccent,
    description: 'Stage 3 — The AI experiments gone wrong.',
  ),
  MapModel(
    name: 'AI Core',
    backgroundColor: Color(0xFF0D0000),
    gridColor: Colors.redAccent,
    accentColor: Colors.redAccent,
    description: 'Stage 4 — Final battle at the AI Core.',
  ),
];
