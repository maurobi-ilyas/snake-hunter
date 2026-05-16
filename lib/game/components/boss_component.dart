import '../models/position_model.dart';

class BossComponent {
  PositionModel position;
  int hp;
  int maxHp;
  int moveCounter = 0;

  BossComponent({
    int startX = 10,
    int startY = 5,
    this.hp = 10,
    this.maxHp = 10,
  }) : position = PositionModel(x: startX, y: startY);
}
