import 'package:flame/components.dart';
import 'dart:collection';

class CollisionGrid {
  final double cellSize;
  final Map<int, Set<PositionComponent>> _grid = HashMap();

  CollisionGrid({this.cellSize = 100.0});

  int _hash(double x, double y) {
    int gx = (x / cellSize).floor();
    int gy = (y / cellSize).floor();
    return (gx * 31) + gy;
  }

  void update(List<PositionComponent> entities) {
    _grid.clear();
    for (var entity in entities) {
      if (!entity.isMounted) continue;
      final h = _hash(entity.position.x, entity.position.y);
      _grid.putIfAbsent(h, () => {}).add(entity);
    }
  }

  Iterable<PositionComponent> getNearby(Vector2 position) {
    final h = _hash(position.x, position.y);
    return _grid[h] ?? const [];
  }
}
