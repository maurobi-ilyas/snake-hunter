class PositionModel {
  int x;
  int y;

  PositionModel({
    required this.x,
    required this.y,
  });

  PositionModel copyWith({
    int? x,
    int? y,
  }) {
    return PositionModel(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionModel &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
