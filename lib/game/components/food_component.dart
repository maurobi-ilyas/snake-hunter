import '../models/position_model.dart';

enum FoodType {
  normal,
  poison,
  speed,
}

class FoodComponent {
  PositionModel position;
  FoodType type;

  FoodComponent({
    required this.position,
    required this.type,
  });
}
