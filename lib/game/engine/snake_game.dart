import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/services/audio_service.dart';
import '../../core/services/effect_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/local_storage_service.dart';
import '../components/boss_component.dart';
import '../components/enemy_snake_component.dart';
import '../components/food_component.dart';
import '../components/obstacle_component.dart';
import '../components/snake_component.dart';
import '../config/game_config.dart';
import '../logic/map_data.dart';
import '../models/direction.dart';
import '../models/position_model.dart';

class SnakeGame extends FlameGame {
  // ── Components ──────────────────────────────────────────
  late SnakeComponent snake;
  late FoodComponent food;
  late EnemySnakeComponent enemySnake;
  late BossComponent boss;
  List<ObstacleComponent> obstacles = [];

  // ── State ────────────────────────────────────────────────
  Direction direction = Direction.right;
  Direction? _nextDirection;
  Timer? gameTimer;

  int score     = 0;
  int coins     = 0;
  int combo     = 0;
  int level     = 1;
  int stage     = 1;
  int highScore = 0;
  double currentSpeed = GameConfig.gameSpeed;
  String playerName = 'Guest Player';

  bool bossMode    = false;
  bool isGameOver  = false;
  bool cameraShake = false;

  // ── Particle pulse ────────────────────────────────────────
  double _pulseT = 0.0;

  // ── Skin ────────────────────────────────────────────────
  Color skinColor = Colors.greenAccent;
  Color skinDark  = const Color(0xFF1B5E20);

  // ── Notifiers ────────────────────────────────────────────
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);
  final ValueNotifier<int> coinsNotifier = ValueNotifier(0);
  final ValueNotifier<int> stageNotifier = ValueNotifier(1);
  final ValueNotifier<int> comboNotifier = ValueNotifier(0);

  final Random random = Random();

  // ── Lifecycle ────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    highScore  = await LocalStorageService.getHighScore();
    playerName = LocalStorageService.getPlayerName();
    _loadSkinColor();
    initializeGame();
  }

  void _loadSkinColor() {
    switch (LocalStorageService.getSkin()) {
      case 'blue_plasma':   skinColor = Colors.blueAccent;   skinDark = const Color(0xFF0D47A1); break;
      case 'purple_shadow': skinColor = Colors.purpleAccent; skinDark = const Color(0xFF4A148C); break;
      case 'red_inferno':   skinColor = Colors.redAccent;    skinDark = const Color(0xFF7F0000); break;
      case 'gold_legend':   skinColor = Colors.amber;        skinDark = const Color(0xFF7B4F00); break;
      case 'cyan_frost':    skinColor = Colors.cyanAccent;   skinDark = const Color(0xFF006064); break;
      default:              skinColor = Colors.greenAccent;  skinDark = const Color(0xFF1B5E20);
    }
  }

  void initializeGame() {
    snake      = SnakeComponent();
    enemySnake = EnemySnakeComponent();
    boss       = BossComponent();
    score      = 0;
    coins      = 0;
    combo      = 0;
    level      = 1;
    stage      = 1;
    bossMode   = false;
    cameraShake = false;
    currentSpeed  = GameConfig.gameSpeed;
    isGameOver    = false;
    direction     = Direction.right;
    _nextDirection = null;
    _pulseT       = 0.0;
    scoreNotifier.value = 0;
    levelNotifier.value = 1;
    coinsNotifier.value = 0;
    stageNotifier.value = 1;
    comboNotifier.value = 0;
    generateFood();
    generateObstacles();
    startGameLoop();
  }

  // ── Game Loop ────────────────────────────────────────────

  void startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(
      Duration(milliseconds: (currentSpeed * 1000).toInt()),
      (_) {
        if (_nextDirection != null) {
          direction = _nextDirection!;
          _nextDirection = null;
        }
        moveSnake();
      },
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Animate food pulse
    _pulseT = (_pulseT + dt * 3.0) % (2 * pi);
    // Auto-clear camera shake
    if (cameraShake) {
      Future.delayed(const Duration(milliseconds: 160), () => cameraShake = false);
    }
  }

  void moveSnake() {
    if (isGameOver) return;

    final head = snake.body.first.copyWith();
    switch (direction) {
      case Direction.up:    head.y -= 1; break;
      case Direction.down:  head.y += 1; break;
      case Direction.left:  head.x -= 1; break;
      case Direction.right: head.x += 1; break;
    }

    checkWallCollision(head);
    checkObstacleCollision(head);
    checkBossCollision(head);
    if (isGameOver) return;

    snake.body.insert(0, head);

    if (head == food.position) {
      handleFoodEffect();
      generateFood();
    } else {
      snake.body.removeLast();
      combo = 0; // reset combo if no food eaten this tick
      comboNotifier.value = 0;
    }

    checkSelfCollision();
    if (isGameOver) return;
    moveEnemySnake();
    moveBoss();
  }

  // ── Food ─────────────────────────────────────────────────

  void handleFoodEffect() {
    switch (food.type) {
      case FoodType.normal:
        score++;
        combo++;
        if (combo > 99) combo = 99;
        final bonus = combo >= 5 ? 3 : (combo >= 3 ? 2 : 1);
        coins += bonus * 2;
        scoreNotifier.value = score;
        coinsNotifier.value = coins;
        comboNotifier.value = combo;
        AudioService.playEat();
        EffectService.vibrateShort();
        break;

      case FoodType.poison:
        gameOver(); return;

      case FoodType.speed:
        score += 2;
        combo++;
        if (combo > 99) combo = 99;
        coins += 5;
        scoreNotifier.value = score;
        coinsNotifier.value = coins;
        comboNotifier.value = combo;
        currentSpeed = (currentSpeed * 0.9).clamp(0.06, 1.0);
        AudioService.playEat();
        EffectService.vibrateShort();
        startGameLoop();
        break;
    }
    updateLevelAndStage();
  }

  void updateLevelAndStage() {
    final newLevel = (score ~/ 5) + 1;
    if (newLevel != level) {
      level = newLevel;
      levelNotifier.value = level;
      currentSpeed = (GameConfig.gameSpeed - (level - 1) * 0.01).clamp(0.06, 1.0);
      startGameLoop();
    }

    final newStage = ((score ~/ 15) + 1).clamp(1, 4);
    if (newStage != stage) {
      stage = newStage;
      stageNotifier.value = stage;
      generateObstacles();
    }

    if (score >= 30 && !bossMode) {
      bossMode = true;
      boss = BossComponent(startX: random.nextInt(GameConfig.columns - 2) + 1, startY: 3);
    }
  }

  void generateFood() {
    final typeRoll = random.nextInt(10);
    FoodType type;
    if (typeRoll >= 8)      type = FoodType.poison;
    else if (typeRoll >= 6) type = FoodType.speed;
    else                    type = FoodType.normal;

    PositionModel pos = PositionModel(x: 0, y: 0);
    bool invalidPosition = true;
    int attempts = 0;
    while (invalidPosition && attempts < 200) {
      pos = PositionModel(x: random.nextInt(GameConfig.columns), y: random.nextInt(GameConfig.rows));
      invalidPosition = snake.body.contains(pos) || 
                        enemySnake.body.contains(pos) || 
                        obstacles.any((o) => o.position == pos) ||
                        (bossMode && boss.position == pos);
      attempts++;
      if (!invalidPosition) {
        food = FoodComponent(position: pos, type: type);
      }
    }
    // Fallback if loop exhausts
    if (invalidPosition) food = FoodComponent(position: pos, type: type);
  }

  void generateObstacles() {
    obstacles.clear();
    final count = (4 + (stage - 1) * 2).clamp(4, 12);
    for (int i = 0; i < count; i++) {
      PositionModel pos;
      int attempts = 0;
      do {
        pos = PositionModel(x: random.nextInt(GameConfig.columns), y: random.nextInt(GameConfig.rows));
        attempts++;
      } while (attempts < 100 && (snake.body.contains(pos) || enemySnake.body.contains(pos)));
      obstacles.add(ObstacleComponent(position: pos));
    }
  }

  // ── Collisions ──────────────────────────────────────────

  void checkWallCollision(PositionModel head) {
    if (head.x < 0 || head.y < 0 || head.x >= GameConfig.columns || head.y >= GameConfig.rows) gameOver();
  }

  void checkObstacleCollision(PositionModel head) {
    for (final o in obstacles) { if (head == o.position) { gameOver(); return; } }
  }

  void checkSelfCollision() {
    final head = snake.body.first;
    for (int i = 1; i < snake.body.length; i++) { if (head == snake.body[i]) { gameOver(); return; } }
  }

  void checkBossCollision(PositionModel head) {
    if (!bossMode) return;
    if (head.x == boss.position.x && head.y == boss.position.y) {
      boss.hp--;
      EffectService.vibrateBossHit();
      cameraShake = true;
      if (boss.hp <= 0) {
        bossMode = false;
        score += 20;
        coins += 50;
        scoreNotifier.value = score;
        coinsNotifier.value = coins;
      }
    }
  }

  // ── AI ───────────────────────────────────────────────────

  void moveEnemySnake() {
    if (isGameOver) return;
    final head = enemySnake.body.first.copyWith();
    if (head.x < food.position.x) head.x++;
    else if (head.x > food.position.x) head.x--;
    else if (head.y < food.position.y) head.y++;
    else if (head.y > food.position.y) head.y--;
    head.x = head.x.clamp(0, GameConfig.columns - 1);
    head.y = head.y.clamp(0, GameConfig.rows - 1);
    enemySnake.body.insert(0, head);
    enemySnake.body.removeLast();
    if (head == snake.body.first) gameOver();
    if (head == food.position) generateFood();
  }

  void moveBoss() {
    if (!bossMode || isGameOver) return;
    boss.moveCounter++;
    if (boss.moveCounter % 3 != 0) return;
    final head = snake.body.first;
    if (boss.position.x < head.x) boss.position.x++;
    else if (boss.position.x > head.x) boss.position.x--;
    else if (boss.position.y < head.y) boss.position.y++;
    else if (boss.position.y > head.y) boss.position.y--;
    boss.position.x = boss.position.x.clamp(0, GameConfig.columns - 2);
    boss.position.y = boss.position.y.clamp(0, GameConfig.rows - 2);
    if (boss.position == head) gameOver();
  }

  // ── Game Over ────────────────────────────────────────────

  void gameOver() {
    if (isGameOver) return;
    isGameOver  = true;
    cameraShake = true;
    gameTimer?.cancel();
    AudioService.playGameOver();
    EffectService.vibrateGameOver();
    LocalStorageService.saveHighScore(score);
    LocalStorageService.addCoins(coins);
    if (score > highScore) highScore = score;
    FirestoreService.saveScore(playerName: playerName, score: score, level: level, coins: coins);
  }

  void restartGame() => initializeGame();

  void changeDirection(Direction newDir) {
    if (direction == Direction.up    && newDir == Direction.down)  return;
    if (direction == Direction.down  && newDir == Direction.up)    return;
    if (direction == Direction.left  && newDir == Direction.right) return;
    if (direction == Direction.right && newDir == Direction.left)  return;
    _nextDirection = newDir;
  }

  // ── Render ──────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    final map = gameMaps[(stage - 1).clamp(0, 3)];

    // Camera shake offset
    final shakeX = cameraShake ? (random.nextDouble() - 0.5) * 2 : 0.0;
    final shakeY = cameraShake ? (random.nextDouble() - 0.5) * 2 : 0.0;

    canvas.save();
    canvas.translate(shakeX, shakeY);

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = map.backgroundColor);
    super.render(canvas);

    if (level < 5) {
      drawGrid(canvas, map.gridColor);
    }
    
    drawObstacles(canvas);
    drawFood(canvas);
    drawEnemySnake(canvas);
    if (bossMode) drawBoss(canvas);
    drawSnake(canvas);
    drawHUD(canvas, map.accentColor);
    if (isGameOver) drawGameOver(canvas);

    canvas.restore();
  }

  void drawGrid(Canvas canvas, Color gridColor) {
    final p = Paint()
      ..color = gridColor.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;
    for (int r = 0; r < GameConfig.rows; r++) {
      for (int c = 0; c < GameConfig.columns; c++) {
        canvas.drawRect(Rect.fromLTWH(c * GameConfig.cellSize, r * GameConfig.cellSize, GameConfig.cellSize, GameConfig.cellSize), p);
      }
    }
  }

  void drawSnake(Canvas canvas) {
    for (int i = 0; i < snake.body.length; i++) {
      final part = snake.body[i];
      final t = i / snake.body.length.clamp(1, 999);
      final color = Color.lerp(skinColor, skinDark, t)!;
      final rect = Rect.fromLTWH(part.x * GameConfig.cellSize + 1.5, part.y * GameConfig.cellSize + 1.5, GameConfig.cellSize - 3, GameConfig.cellSize - 3);
      if (i == 0) {
        // Animated head glow
        final glowR = 4.0 + sin(_pulseT) * 1.5;
        canvas.drawRRect(RRect.fromRectAndRadius(rect.inflate(glowR), const Radius.circular(6)),
          Paint()..color = skinColor.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5));
      }
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = color);
    }
  }

  void drawEnemySnake(Canvas canvas) {
    for (int i = 0; i < enemySnake.body.length; i++) {
      final part = enemySnake.body[i];
      final t = i / enemySnake.body.length.clamp(1, 999);
      final color = Color.lerp(Colors.orangeAccent, const Color(0xFF7B3F00), t)!;
      final rect = Rect.fromLTWH(part.x * GameConfig.cellSize + 1.5, part.y * GameConfig.cellSize + 1.5, GameConfig.cellSize - 3, GameConfig.cellSize - 3);
      if (i == 0) {
        canvas.drawRRect(RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(5)),
          Paint()..color = Colors.orangeAccent.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4));
      }
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = color);
    }
  }

  void drawBoss(Canvas canvas) {
    final bx = boss.position.x * GameConfig.cellSize;
    final by = boss.position.y * GameConfig.cellSize;
    final bSize = GameConfig.cellSize * 2;
    final rect = Rect.fromLTWH(bx, by, bSize, bSize);

    // Pulsing glow
    final glowOpacity = 0.2 + sin(_pulseT) * 0.15;
    canvas.drawRect(rect.inflate(6),
      Paint()..color = Colors.redAccent.withOpacity(glowOpacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = Colors.red.shade900);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = Colors.redAccent..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // HP bar
    final hpRatio = boss.hp / boss.maxHp;
    canvas.drawRect(Rect.fromLTWH(bx, by - 8, bSize, 4), Paint()..color = Colors.white12);
    canvas.drawRect(Rect.fromLTWH(bx, by - 8, bSize * hpRatio, 4),
      Paint()..color = Color.lerp(Colors.redAccent, Colors.greenAccent, hpRatio)!);

    final tp = TextPainter(
      text: const TextSpan(text: '👾 BOSS', style: TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(bx, by - 18));
  }

  void drawFood(Canvas canvas) {
    final foodColor = switch (food.type) {
      FoodType.normal => Colors.redAccent,
      FoodType.poison => Colors.purpleAccent,
      FoodType.speed  => Colors.blueAccent,
    };

    final cx = food.position.x * GameConfig.cellSize + GameConfig.cellSize / 2;
    final cy = food.position.y * GameConfig.cellSize + GameConfig.cellSize / 2;
    final r = GameConfig.cellSize / 2 - 2;

    // Animated outer particle glow
    final outerR = r + 5 + sin(_pulseT) * 2;
    canvas.drawCircle(Offset(cx, cy), outerR,
      Paint()..color = foodColor.withOpacity(0.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Inner glow
    canvas.drawCircle(Offset(cx, cy), r + 2,
      Paint()..color = foodColor.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Body
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = foodColor);

    // Shine
    canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.3), r * 0.3, Paint()..color = Colors.white.withOpacity(0.5));

    // Type label
    if (food.type != FoodType.normal) {
      final label = food.type == FoodType.poison ? '☠' : '⚡';
      final tp = TextPainter(text: TextSpan(text: label, style: const TextStyle(fontSize: 9)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - r - 11));
    }
  }

  void drawObstacles(Canvas canvas) {
    for (final o in obstacles) {
      final rect = Rect.fromLTWH(o.position.x * GameConfig.cellSize, o.position.y * GameConfig.cellSize, GameConfig.cellSize, GameConfig.cellSize);
      canvas.drawRRect(RRect.fromRectAndRadius(rect.shift(const Offset(1,1)), const Radius.circular(3)), Paint()..color = Colors.black45);
      canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(3)), Paint()..color = const Color(0xFF546E7A));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left+2, rect.top+2, rect.width*0.4, rect.height*0.4), const Radius.circular(2)), Paint()..color = Colors.white24);
    }
  }

  void drawHUD(Canvas canvas, Color accent) {
    _text(canvas, 'SCORE  $score', const Offset(8, 4),  accent,              12);
    _text(canvas, 'LVL  $level',   const Offset(8, 20), Colors.yellowAccent, 11);
    _text(canvas, '🪙 $coins',     const Offset(8, 35), Colors.amber,        11);

    // Combo (only show if > 1)
    if (combo > 1) {
      final comboColor = combo >= 10 ? Colors.redAccent : combo >= 5 ? Colors.orangeAccent : Colors.yellowAccent;
      final tp = TextPainter(
        text: TextSpan(text: '🔥 x$combo', style: TextStyle(
          color: comboColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: comboColor, blurRadius: 10)],
        )),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, const Offset(8, 50));
    }

    // Stage name top center
    final mapName = gameMaps[(stage - 1).clamp(0, 3)].name;
    final stageTP = TextPainter(
      text: TextSpan(text: 'S$stage — $mapName',
          style: TextStyle(color: accent.withOpacity(0.65), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    stageTP.paint(canvas, Offset(size.x / 2 - stageTP.width / 2, 5));

    // Best score top right
    final hsTP = TextPainter(
      text: TextSpan(text: 'BEST $highScore', style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    hsTP.paint(canvas, Offset(size.x - hsTP.width - 6, 6));

    // Boss HP warning
    if (bossMode) {
      final wTP = TextPainter(
        text: TextSpan(text: '⚠ BOSS ${boss.hp}/${boss.maxHp}',
            style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      wTP.paint(canvas, Offset(size.x - wTP.width - 6, 20));
    }
  }

  void _text(Canvas canvas, String text, Offset offset, Color color, double sz) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: sz, fontWeight: FontWeight.bold, letterSpacing: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void drawGameOver(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = Colors.black.withOpacity(0.82));
    _centered(canvas, 'GAME OVER',        26, Colors.redAccent,   -60);
    _centered(canvas, 'SCORE  $score',    18, Colors.white70,     -22);
    _centered(canvas, 'COMBO x$combo',    13, Colors.yellowAccent, -2);
    _centered(canvas, 'STAGE  $stage',    13, Colors.cyanAccent,   16);
    _centered(canvas, '🪙 COINS  $coins', 12, Colors.amber,        34);
    _centered(canvas, 'BEST  $highScore', 11, Colors.white38,      52);
    _centered(canvas, '▼ TAP RESTART',     9, Colors.white24,      70);
  }

  void _centered(Canvas canvas, String text, double fontSize, Color color, double dy) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, letterSpacing: 2,
          shadows: [Shadow(color: color.withOpacity(0.6), blurRadius: 10)])),
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
    stageNotifier.dispose();
    comboNotifier.dispose();
    super.onRemove();
  }
}
