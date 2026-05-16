import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../components/food_component.dart';
import '../components/snake_component.dart';
import '../config/game_config.dart';
import '../models/direction.dart';
import '../models/position_model.dart';

class SnakeGame extends FlameGame {
  late SnakeComponent snake;
  late FoodComponent food;

  Direction direction = Direction.right;
  Direction? _nextDirection;

  Timer? gameTimer;

  int score = 0;
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  bool isGameOver = false;

  final Random random = Random();

  @override
  Future<void> onLoad() async {
    initializeGame();
  }

  void initializeGame() {
    snake = SnakeComponent();
    generateFood();
    score = 0;
    scoreNotifier.value = 0;
    isGameOver = false;
    direction = Direction.right;
    _nextDirection = null;
    startGameLoop();
  }

  void startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(
      Duration(milliseconds: (GameConfig.gameSpeed * 1000).toInt()),
      (timer) {
        // Apply buffered direction change
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

    // Wall collision
    if (head.x < 0 ||
        head.y < 0 ||
        head.x >= GameConfig.columns ||
        head.y >= GameConfig.rows) {
      gameOver();
      return;
    }

    snake.body.insert(0, head);

    // Food collision
    if (head == food.position) {
      score++;
      scoreNotifier.value = score;
      generateFood();
      // Don't removeLast → snake grows
    } else {
      snake.body.removeLast();
    }

    // Self collision
    for (int i = 1; i < snake.body.length; i++) {
      if (snake.body.first == snake.body[i]) {
        gameOver();
        return;
      }
    }
  }

  void generateFood() {
    PositionModel pos;
    // Ensure food doesn't spawn on snake
    do {
      pos = PositionModel(
        x: random.nextInt(GameConfig.columns),
        y: random.nextInt(GameConfig.rows),
      );
    } while (snake.body.contains(pos));
    food = FoodComponent(position: pos);
  }

  void gameOver() {
    isGameOver = true;
    gameTimer?.cancel();
  }

  void restartGame() {
    initializeGame();
  }

  void changeDirection(Direction newDirection) {
    // Prevent reversing
    if (direction == Direction.up && newDirection == Direction.down) return;
    if (direction == Direction.down && newDirection == Direction.up) return;
    if (direction == Direction.left && newDirection == Direction.right) return;
    if (direction == Direction.right && newDirection == Direction.left) return;

    // Buffer the input so it applies on next tick
    _nextDirection = newDirection;
  }

  @override
  void render(Canvas canvas) {
    // Dark background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFF0D1117),
    );

    super.render(canvas);

    drawGrid(canvas);
    drawFood(canvas);
    drawSnake(canvas);
    drawScore(canvas);

    if (isGameOver) {
      drawGameOver(canvas);
    }
  }

  void drawGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = const Color(0xFF161B22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int row = 0; row < GameConfig.rows; row++) {
      for (int col = 0; col < GameConfig.columns; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            col * GameConfig.cellSize,
            row * GameConfig.cellSize,
            GameConfig.cellSize,
            GameConfig.cellSize,
          ),
          gridPaint,
        );
      }
    }
  }

  void drawSnake(Canvas canvas) {
    for (int i = 0; i < snake.body.length; i++) {
      final part = snake.body[i];
      final isHead = i == 0;
      final t = i / snake.body.length.clamp(1, 999);

      // Gradient: bright at head, dark at tail
      final color = Color.lerp(
        Colors.greenAccent,
        const Color(0xFF1B5E20),
        t,
      )!;

      final rect = Rect.fromLTWH(
        part.x * GameConfig.cellSize + 1.5,
        part.y * GameConfig.cellSize + 1.5,
        GameConfig.cellSize - 3,
        GameConfig.cellSize - 3,
      );

      // Glow on head
      if (isHead) {
        canvas.drawRect(
          rect.inflate(3),
          Paint()
            ..color = Colors.greenAccent.withOpacity(0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = color,
      );
    }
  }

  void drawFood(Canvas canvas) {
    final cx = food.position.x * GameConfig.cellSize + GameConfig.cellSize / 2;
    final cy = food.position.y * GameConfig.cellSize + GameConfig.cellSize / 2;
    final r = GameConfig.cellSize / 2 - 2;

    // Glow
    canvas.drawCircle(
      Offset(cx, cy),
      r + 3,
      Paint()
        ..color = Colors.redAccent.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // Apple-like circle
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.redAccent);
    canvas.drawCircle(
      Offset(cx - r * 0.25, cy - r * 0.25),
      r * 0.35,
      Paint()..color = Colors.red.shade300,
    );
  }

  void drawScore(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'SCORE  $score',
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(8, 8));
  }

  void drawGameOver(Canvas canvas) {
    // Dim overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black.withOpacity(0.65),
    );

    void drawCenteredText(String text, double fontSize, Color color, double offsetY) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y / 2 + offsetY));
    }

    drawCenteredText('GAME OVER', 28, Colors.redAccent, -30);
    drawCenteredText('Score: $score', 18, Colors.white70, 10);
    drawCenteredText('Tap RESTART below', 13, Colors.white38, 38);
  }

  @override
  void onRemove() {
    gameTimer?.cancel();
    scoreNotifier.dispose();
    super.onRemove();
  }
}
