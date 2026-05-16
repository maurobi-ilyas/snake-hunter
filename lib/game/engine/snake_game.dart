import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/local_storage_service.dart';
import '../components/enemy_snake_component.dart';
import '../components/food_component.dart';
import '../components/obstacle_component.dart';
import '../components/snake_component.dart';
import '../config/game_config.dart';
import '../models/direction.dart';
import '../models/position_model.dart';

class SnakeGame extends FlameGame {
  late SnakeComponent snake;
  late FoodComponent food;
  late EnemySnakeComponent enemySnake;
  List<ObstacleComponent> obstacles = [];

  Direction direction = Direction.right;
  Direction? _nextDirection;

  Timer? gameTimer;

  int score = 0;
  int coins = 0;
  int level = 1;
  int highScore = 0;
  double currentSpeed = GameConfig.gameSpeed;
  String playerName = 'Guest Player';

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);

  bool isGameOver = false;
  Color skinColor = const Color(0xFF69FF47); // default green neon
  Color skinDark  = const Color(0xFF1B5E20);

  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Load persistent data
    highScore = await LocalStorageService.getHighScore();
    playerName = LocalStorageService.getPlayerName();
    _loadSkinColor();
    initializeGame();
  }

  void _loadSkinColor() {
    final skin = LocalStorageService.getSkin();
    switch (skin) {
      case 'blue_plasma':
        skinColor = Colors.blueAccent;
        skinDark  = const Color(0xFF0D47A1);
        break;
      case 'purple_shadow':
        skinColor = Colors.purpleAccent;
        skinDark  = const Color(0xFF4A148C);
        break;
      case 'red_inferno':
        skinColor = Colors.redAccent;
        skinDark  = const Color(0xFF7F0000);
        break;
      case 'gold_legend':
        skinColor = Colors.amber;
        skinDark  = const Color(0xFF7B4F00);
        break;
      case 'cyan_frost':
        skinColor = Colors.cyanAccent;
        skinDark  = const Color(0xFF006064);
        break;
      default:
        skinColor = Colors.greenAccent;
        skinDark  = const Color(0xFF1B5E20);
    }
  }

  void initializeGame() {
    snake = SnakeComponent();
    enemySnake = EnemySnakeComponent();
    score = 0;
    coins = 0;
    level = 1;
    currentSpeed = GameConfig.gameSpeed;
    scoreNotifier.value = 0;
    levelNotifier.value = 1;
    coinsNotifier.value = 0;
    isGameOver = false;
    direction = Direction.right;
    _nextDirection = null;
    generateFood();
    generateObstacles();
    startGameLoop();
  }

  void startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(
      Duration(milliseconds: (currentSpeed * 1000).toInt()),
      (timer) {
        if (_nextDirection != null) {
          direction = _nextDirection!;
          _nextDirection = null;
        }
        moveSnake();
      },
    );
  }

  void moveSnake() {
    if (isGameOver) return;

    PositionModel head = snake.body.first.copyWith();

    switch (direction) {
      case Direction.up:
        head.y -= 1;
        break;
      case Direction.down:
        head.y += 1;
        break;
      case Direction.left:
        head.x -= 1;
        break;
      case Direction.right:
        head.x += 1;
        break;
    }

    checkWallCollision(head);
    checkObstacleCollision(head);
    if (isGameOver) return;

    snake.body.insert(0, head);

    if (head == food.position) {
      handleFoodEffect();
      generateFood();
    } else {
      snake.body.removeLast();
    }

    checkSelfCollision();
    if (isGameOver) return;

    moveEnemySnake();
  }

  void handleFoodEffect() {
    switch (food.type) {
      case FoodType.normal:
        score++;
        coins += 2;
        scoreNotifier.value = score;
        coinsNotifier.value = coins;
        AudioService.playEat();
        break;

      case FoodType.poison:
        gameOver();
        return;

      case FoodType.speed:
        score += 2;
        coins += 5;
        scoreNotifier.value = score;
        coinsNotifier.value = coins;
        currentSpeed = (currentSpeed * 0.9).clamp(0.06, 1.0);
        AudioService.playEat();
        startGameLoop();
        break;
    }
    updateLevel();
  }

  void updateLevel() {
    final newLevel = (score ~/ 5) + 1;
    if (newLevel != level) {
      level = newLevel;
      levelNotifier.value = level;
      currentSpeed = (GameConfig.gameSpeed - (level - 1) * 0.01).clamp(0.06, 1.0);
      startGameLoop();
    }
  }

  void generateFood() {
    final typeRoll = random.nextInt(10);
    FoodType type;
    if (typeRoll >= 8) {
      type = FoodType.poison;
    } else if (typeRoll >= 6) {
      type = FoodType.speed;
    } else {
      type = FoodType.normal;
    }

    PositionModel pos;
    int attempts = 0;
    do {
      pos = PositionModel(
        x: random.nextInt(GameConfig.columns),
        y: random.nextInt(GameConfig.rows),
      );
      attempts++;
    } while (
        attempts < 100 &&
        (snake.body.contains(pos) ||
            enemySnake.body.contains(pos) ||
            obstacles.any((o) => o.position == pos)));

    food = FoodComponent(position: pos, type: type);
  }

  void generateObstacles() {
    obstacles.clear();
    final count = 4 + (level - 1).clamp(0, 8);
    for (int i = 0; i < count; i++) {
      PositionModel pos;
      int attempts = 0;
      do {
        pos = PositionModel(
          x: random.nextInt(GameConfig.columns),
          y: random.nextInt(GameConfig.rows),
        );
        attempts++;
      } while (
          attempts < 100 &&
          (snake.body.contains(pos) || enemySnake.body.contains(pos)));
      obstacles.add(ObstacleComponent(position: pos));
    }
  }

  void checkWallCollision(PositionModel head) {
    if (head.x < 0 || head.y < 0 || head.x >= GameConfig.columns || head.y >= GameConfig.rows) {
      gameOver();
    }
  }

  void checkObstacleCollision(PositionModel head) {
    for (final obstacle in obstacles) {
      if (head == obstacle.position) {
        gameOver();
        return;
      }
    }
  }

  void checkSelfCollision() {
    final head = snake.body.first;
    for (int i = 1; i < snake.body.length; i++) {
      if (head == snake.body[i]) {
        gameOver();
        return;
      }
    }
  }

  void moveEnemySnake() {
    if (isGameOver) return;

    final head = enemySnake.body.first.copyWith();

    if (head.x < food.position.x) {
      head.x++;
    } else if (head.x > food.position.x) {
      head.x--;
    } else if (head.y < food.position.y) {
      head.y++;
    } else if (head.y > food.position.y) {
      head.y--;
    }

    head.x = head.x.clamp(0, GameConfig.columns - 1);
    head.y = head.y.clamp(0, GameConfig.rows - 1);

    enemySnake.body.insert(0, head);
    enemySnake.body.removeLast();

    if (head == snake.body.first) {
      gameOver();
    }

    if (head == food.position) {
      generateFood();
    }
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    gameTimer?.cancel();
    AudioService.playGameOver();

    // Save locally
    LocalStorageService.saveHighScore(score);
    LocalStorageService.addCoins(coins);
    if (score > highScore) highScore = score;

    // Save online (fire and forget — silent fail if no Firebase)
    FirestoreService.saveScore(
      playerName: playerName,
      score: score,
      level: level,
      coins: coins,
    );
  }

  void restartGame() {
    initializeGame();
  }

  void changeDirection(Direction newDirection) {
    if (direction == Direction.up && newDirection == Direction.down) return;
    if (direction == Direction.down && newDirection == Direction.up) return;
    if (direction == Direction.left && newDirection == Direction.right) return;
    if (direction == Direction.right && newDirection == Direction.left) return;
    _nextDirection = newDirection;
  }

  // ─── RENDER ────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF050816),
    );
    super.render(canvas);

    drawGrid(canvas);
    drawObstacles(canvas);
    drawFood(canvas);
    drawEnemySnake(canvas);
    drawSnake(canvas);
    drawHUD(canvas);

    if (isGameOver) drawGameOver(canvas);
  }

  void drawGrid(Canvas canvas) {
    final p = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    for (int r = 0; r < GameConfig.rows; r++) {
      for (int c = 0; c < GameConfig.columns; c++) {
        canvas.drawRect(
          Rect.fromLTWH(c * GameConfig.cellSize, r * GameConfig.cellSize,
              GameConfig.cellSize, GameConfig.cellSize),
          p,
        );
      }
    }
  }

  void drawSnake(Canvas canvas) {
    for (int i = 0; i < snake.body.length; i++) {
      final part = snake.body[i];
      final t = i / snake.body.length.clamp(1, 999);
      final color = Color.lerp(skinColor, skinDark, t)!;
      final rect = Rect.fromLTWH(
        part.x * GameConfig.cellSize + 1.5,
        part.y * GameConfig.cellSize + 1.5,
        GameConfig.cellSize - 3,
        GameConfig.cellSize - 3,
      );

      if (i == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(5)),
          Paint()
            ..color = skinColor.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = color,
      );
    }
  }

  void drawEnemySnake(Canvas canvas) {
    for (int i = 0; i < enemySnake.body.length; i++) {
      final part = enemySnake.body[i];
      final t = i / enemySnake.body.length.clamp(1, 999);
      final color = Color.lerp(Colors.orangeAccent, const Color(0xFF7B3F00), t)!;
      final rect = Rect.fromLTWH(
        part.x * GameConfig.cellSize + 1.5,
        part.y * GameConfig.cellSize + 1.5,
        GameConfig.cellSize - 3,
        GameConfig.cellSize - 3,
      );
      if (i == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(5)),
          Paint()
            ..color = Colors.orangeAccent.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = color,
      );
    }
  }

  void drawFood(Canvas canvas) {
    final foodColor = switch (food.type) {
      FoodType.normal => Colors.redAccent,
      FoodType.poison => Colors.purpleAccent,
      FoodType.speed => Colors.blueAccent,
    };

    final cx = food.position.x * GameConfig.cellSize + GameConfig.cellSize / 2;
    final cy = food.position.y * GameConfig.cellSize + GameConfig.cellSize / 2;
    final r = GameConfig.cellSize / 2 - 2;

    canvas.drawCircle(Offset(cx, cy), r + 4,
      Paint()..color = foodColor.withOpacity(0.3)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = foodColor);
    canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.3), r * 0.3,
      Paint()..color = Colors.white.withOpacity(0.5));

    if (food.type != FoodType.normal) {
      final label = food.type == FoodType.poison ? '☠' : '⚡';
      final tp = TextPainter(
        text: TextSpan(text: label, style: const TextStyle(fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - r - 12));
    }
  }

  void drawObstacles(Canvas canvas) {
    for (final o in obstacles) {
      final rect = Rect.fromLTWH(
        o.position.x * GameConfig.cellSize,
        o.position.y * GameConfig.cellSize,
        GameConfig.cellSize,
        GameConfig.cellSize,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect.shift(const Offset(1,1)), const Radius.circular(3)),
        Paint()..color = Colors.black45);
      canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(3)),
        Paint()..color = const Color(0xFF546E7A));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(rect.left+2, rect.top+2, rect.width*0.4, rect.height*0.4), const Radius.circular(2)),
        Paint()..color = Colors.white24);
    }
  }

  void drawHUD(Canvas canvas) {
    _text(canvas, 'SCORE  $score', const Offset(8, 4), Colors.greenAccent, 12);
    _text(canvas, 'LVL  $level', const Offset(8, 20), Colors.yellowAccent, 11);
    _text(canvas, '🪙 $coins', const Offset(8, 35), Colors.amber, 11);

    // High score top right
    final hs = 'BEST  $highScore';
    final tp = TextPainter(
      text: TextSpan(text: hs, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x - tp.width - 6, 6));
  }

  void _text(Canvas canvas, String text, Offset offset, Color color, double sz) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: sz, fontWeight: FontWeight.bold, letterSpacing: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void drawGameOver(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0,0,size.x,size.y), Paint()..color = Colors.black.withOpacity(0.78));
    _centered(canvas, 'GAME OVER', 26, Colors.redAccent, -55);
    _centered(canvas, 'SCORE  $score', 18, Colors.white70, -18);
    _centered(canvas, 'LEVEL  $level', 14, Colors.yellowAccent, 8);
    _centered(canvas, '🪙 COINS  $coins', 13, Colors.amber, 28);
    _centered(canvas, 'BEST  $highScore', 12, Colors.white38, 48);
    _centered(canvas, '▼ TAP RESTART', 10, Colors.white24, 68);
  }

  void _centered(Canvas canvas, String text, double fontSize, Color color, double dy) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: 2,
        shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 8)])),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y / 2 + dy));
  }

  @override
  void onRemove() {
    gameTimer?.cancel();
    scoreNotifier.dispose();
    levelNotifier.dispose();
    coinsNotifier.dispose();
    super.onRemove();
  }
}
