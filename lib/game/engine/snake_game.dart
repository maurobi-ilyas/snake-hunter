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
  List<FoodComponent> foods = [];
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
  double _waterTime = 0.0;
  List<DecorativeSnake> decoSnakes = [];

  // ── Skin & Settings ─────────────────────────────────────
  Color skinColor = Colors.greenAccent;
  Color skinDark  = const Color(0xFF1B5E20);
  String difficulty = 'normal';

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
    difficulty = LocalStorageService.getDifficulty();
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
    currentSpeed  = difficulty == 'easy' ? 0.16 : (difficulty == 'hard' ? 0.09 : GameConfig.gameSpeed);
    isGameOver    = false;
    direction     = Direction.right;
    _inputQueue.clear();
    _timeSinceLastTick = 0.0;
    _waterTime = 0.0;
    _prevBody.clear();
    _prevEnemyBody.clear();
    _pulseT       = 0.0;
    foods.clear();
    decoSnakes.clear();
    for (int i = 0; i < random.nextInt(3) + 3; i++) {
      decoSnakes.add(DecorativeSnake(random));
    }
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

  final List<Direction> _inputQueue = [];
  double _timeSinceLastTick = 0.0;
  List<PositionModel> _prevBody = [];
  List<PositionModel> _prevEnemyBody = [];

  void queueDirection(Direction newDir) {
    if (_inputQueue.length >= 3) return;
    Direction lastDir = _inputQueue.isNotEmpty ? _inputQueue.last : direction;
    bool isOpposite = false;
    if (lastDir == Direction.up && newDir == Direction.down) isOpposite = true;
    if (lastDir == Direction.down && newDir == Direction.up) isOpposite = true;
    if (lastDir == Direction.left && newDir == Direction.right) isOpposite = true;
    if (lastDir == Direction.right && newDir == Direction.left) isOpposite = true;
    if (!isOpposite && lastDir != newDir) {
      _inputQueue.add(newDir);
    }
  }

  void startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(
      Duration(milliseconds: (currentSpeed * 1000).toInt()),
      (_) {
        if (_inputQueue.isNotEmpty) {
          direction = _inputQueue.removeAt(0);
        }
        _timeSinceLastTick = 0.0;
        _prevBody = snake.body.map((p) => p.copyWith()).toList();
        _prevEnemyBody = enemySnake.body.map((p) => p.copyWith()).toList();
        moveSnake();
      },
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseT = (_pulseT + dt * 3.0) % (2 * pi);
    _waterTime += dt;
    _timeSinceLastTick += dt;
    for (final deco in decoSnakes) deco.update(dt);
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

    FoodComponent? eatenFood;
    for (final f in foods) {
      if (head == f.position) { eatenFood = f; break; }
    }

    if (eatenFood != null) {
      handleFoodEffect(eatenFood);
      foods.remove(eatenFood);
      generateSingleFood();
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

  void handleFoodEffect(FoodComponent eaten) {
    switch (eaten.type) {
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
        score = (score - 5).clamp(0, 99999);
        combo = 0;
        scoreNotifier.value = score;
        comboNotifier.value = combo;
        cameraShake = true;
        EffectService.vibrateBossHit();
        break;

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
    }

    double baseSpd = GameConfig.gameSpeed;
    double speedScale = 0.0025;
    if (difficulty == 'easy') { baseSpd = 0.16; speedScale = 0.0015; }
    else if (difficulty == 'hard') { baseSpd = 0.09; speedScale = 0.0035; }

    currentSpeed = baseSpd - (snake.body.length * speedScale);
    if (currentSpeed < 0.04) currentSpeed = 0.04;
    startGameLoop();

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

  void generateSingleFood() {
    final typeRoll = random.nextInt(10);
    FoodType type;
    if (typeRoll >= 8)      type = FoodType.poison;
    else if (typeRoll >= 6) type = FoodType.speed;
    else                    type = FoodType.normal;

    List<PositionModel> validPositions = [];
    for (int r = 0; r < GameConfig.rows; r++) {
      for (int c = 0; c < GameConfig.columns; c++) {
        final pos = PositionModel(x: c, y: r);
        if (!snake.body.contains(pos) &&
            !enemySnake.body.contains(pos) &&
            !obstacles.any((o) => o.position == pos) &&
            !(bossMode && boss.position == pos) &&
            !foods.any((f) => f.position == pos)) {
          validPositions.add(pos);
        }
      }
    }

    if (validPositions.isNotEmpty) {
      final pos = validPositions[random.nextInt(validPositions.length)];
      foods.add(FoodComponent(position: pos, type: type));
    } else {
      foods.add(FoodComponent(position: PositionModel(x: 0, y: 0), type: type));
    }
  }

  void generateFood() {
    foods.clear();
    for (int i = 0; i < 3; i++) {
      generateSingleFood();
    }
  }

  void generateObstacles() {
    obstacles.clear();
    int count = (4 + (stage - 1) * 2).clamp(4, 12);
    if (difficulty == 'easy') count += 6;
    else if (difficulty == 'hard') count += 4;
    
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
    if (head.x < 0) head.x = GameConfig.columns - 1;
    else if (head.x >= GameConfig.columns) head.x = 0;
    
    if (head.y < 0) head.y = GameConfig.rows - 1;
    else if (head.y >= GameConfig.rows) head.y = 0;
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

  int _aiTickCounter = 0;

  void moveEnemySnake() {
    if (isGameOver) return;

    if (difficulty == 'easy' && score < 15) {
      if (enemySnake.body.isNotEmpty) enemySnake.body.clear();
      return;
    }

    if (enemySnake.body.isEmpty) {
      enemySnake = EnemySnakeComponent();
    }

    // AI nerfing logic (slower speed)
    _aiTickCounter++;
    int skipTicks = difficulty == 'hard' ? 0 : (difficulty == 'easy' ? 2 : 1);
    if (_aiTickCounter % (skipTicks + 1) != 0) return; // Skip movement ticks to make it slower

    final head = enemySnake.body.first.copyWith();

    // AI randomness (chance to move randomly instead of tracking perfectly)
    int randomChance = difficulty == 'easy' ? 40 : (difficulty == 'hard' ? 5 : 20);
    if (random.nextInt(100) < randomChance) {
      final dirs = [[0,-1], [0,1], [-1,0], [1,0]];
      final d = dirs[random.nextInt(4)];
      head.x += d[0]; head.y += d[1];
    } else {
      // Standard tracking closest food
      FoodComponent? targetFood;
      if (foods.isNotEmpty) {
        targetFood = foods.first;
        double minDist = 9999;
        for (final f in foods) {
          double d = (f.position.x - head.x).abs() + (f.position.y - head.y).abs().toDouble();
          if (d < minDist) { minDist = d; targetFood = f; }
        }
      }
      if (targetFood != null) {
        if (head.x < targetFood.position.x) head.x++;
        else if (head.x > targetFood.position.x) head.x--;
        else if (head.y < targetFood.position.y) head.y++;
        else if (head.y > targetFood.position.y) head.y--;
      }
    }
    head.x = head.x.clamp(0, GameConfig.columns - 1);
    head.y = head.y.clamp(0, GameConfig.rows - 1);
    enemySnake.body.insert(0, head);
    
    FoodComponent? eaten;
    for (final f in foods) { if (head == f.position) eaten = f; }
    if (eaten != null) {
      foods.remove(eaten);
      generateSingleFood();
    } else {
      enemySnake.body.removeLast();
    }

    if (head == snake.body.first) gameOver();
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

    // River Theme Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = const Color(0xFF031024)); // Dark blue neon
    
    // Draw water currents / ripples
    final waterPaint = Paint()..color = Colors.cyan.withOpacity(0.06)..style = PaintingStyle.stroke..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      double yOffset = (i * size.y / 8 + _waterTime * 15) % size.y;
      Path wavePath = Path();
      wavePath.moveTo(0, yOffset);
      for (double x = 0; x <= size.x; x += 40) {
        wavePath.lineTo(x, yOffset + sin((x / 50) + _waterTime * 2) * 12);
      }
      canvas.drawPath(wavePath, waterPaint);
    }
    
    // Draw water particles
    final particlePaint = Paint()..color = Colors.cyanAccent.withOpacity(0.25);
    for (int i = 0; i < 20; i++) {
       double px = (i * 73 + _waterTime * 25 * (i % 2 == 0 ? 1 : 1.5)) % size.x;
       double py = (i * 47 + _waterTime * 10) % size.y;
       canvas.drawCircle(Offset(px, py), 1.5, particlePaint);
    }

    super.render(canvas);

    if (level < 5) drawGrid(canvas, map.gridColor);
    
    drawDecorativeSnakes(canvas);
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
    double tProg = (_timeSinceLastTick / currentSpeed).clamp(0.0, 1.0);
    final List<PositionModel> currentBody = snake.body.toList();

    for (int i = currentBody.length - 1; i >= 0; i--) {
      final part = currentBody[i];
      final t = i / currentBody.length.clamp(1, 999);
      final color = Color.lerp(skinColor, skinDark, t)!;
      double x = part.x * GameConfig.cellSize + GameConfig.cellSize / 2;
      double y = part.y * GameConfig.cellSize + GameConfig.cellSize / 2;

      // Interpolation logic
      if (_prevBody.length > i) {
        double px = _prevBody[i].x * GameConfig.cellSize + GameConfig.cellSize / 2;
        double py = _prevBody[i].y * GameConfig.cellSize + GameConfig.cellSize / 2;
        if ((x - px).abs() <= GameConfig.cellSize * 1.5 && (y - py).abs() <= GameConfig.cellSize * 1.5) {
          x = px + (x - px) * tProg;
          y = py + (y - py) * tProg;
        }
      }

      final radius = GameConfig.cellSize / 2.2;

      if (i == 0) {
        final glowR = radius + 3 + sin(_pulseT) * 1.5;
        canvas.drawCircle(Offset(x, y), glowR,
          Paint()..color = skinColor.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5));
      }

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..shader = RadialGradient(colors: [skinColor, color]).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius))
          ..color = color.withOpacity(0.9),
      );

      if (i == 0) _drawHeadFeatures(canvas, x, y, radius, direction);
    }
  }

  void drawEnemySnake(Canvas canvas) {
    double tProg = (_timeSinceLastTick / currentSpeed).clamp(0.0, 1.0);
    final List<PositionModel> currentEnemyBody = enemySnake.body.toList();

    for (int i = currentEnemyBody.length - 1; i >= 0; i--) {
      final part = currentEnemyBody[i];
      final t = i / currentEnemyBody.length.clamp(1, 999);
      final color = Color.lerp(Colors.orangeAccent, const Color(0xFF7B3F00), t)!;
      double x = part.x * GameConfig.cellSize + GameConfig.cellSize / 2;
      double y = part.y * GameConfig.cellSize + GameConfig.cellSize / 2;

      // Interpolation logic
      if (_prevEnemyBody.length > i) {
        double px = _prevEnemyBody[i].x * GameConfig.cellSize + GameConfig.cellSize / 2;
        double py = _prevEnemyBody[i].y * GameConfig.cellSize + GameConfig.cellSize / 2;
        if ((x - px).abs() <= GameConfig.cellSize * 1.5 && (y - py).abs() <= GameConfig.cellSize * 1.5) {
          x = px + (x - px) * tProg;
          y = py + (y - py) * tProg;
        }
      }

      final radius = GameConfig.cellSize / 2.2;

      if (i == 0) {
        canvas.drawCircle(Offset(x, y), radius + 2,
          Paint()..color = Colors.orangeAccent.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4));
      }

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..shader = RadialGradient(colors: [Colors.orangeAccent, color]).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius))
          ..color = color.withOpacity(0.9),
      );

      if (i == 0) {
        Direction dir = Direction.right;
        if (enemySnake.body.length > 1) {
           final p2 = enemySnake.body[1];
           if (part.x > p2.x) dir = Direction.right;
           else if (part.x < p2.x) dir = Direction.left;
           else if (part.y > p2.y) dir = Direction.down;
           else if (part.y < p2.y) dir = Direction.up;
        }
        _drawHeadFeatures(canvas, x, y, radius, dir);
      }
    }
  }

  void _drawHeadFeatures(Canvas canvas, double x, double y, double r, Direction dir) {
    final eyeP = Paint()..color = Colors.white;
    final pupilP = Paint()..color = Colors.black;
    final tongueP = Paint()..color = Colors.redAccent..strokeWidth = 1.5;

    double dx = 0, dy = 0;
    if (dir == Direction.up) dy = -1;
    if (dir == Direction.down) dy = 1;
    if (dir == Direction.left) dx = -1;
    if (dir == Direction.right) dx = 1;

    final double eOx = (dir == Direction.up || dir == Direction.down) ? r * 0.4 : 0;
    final double eOy = (dir == Direction.left || dir == Direction.right) ? r * 0.4 : 0;
    
    final eye1X = x + dx * r * 0.3 + eOx;
    final eye1Y = y + dy * r * 0.3 + eOy;
    final eye2X = x + dx * r * 0.3 - eOx;
    final eye2Y = y + dy * r * 0.3 - eOy;

    canvas.drawCircle(Offset(eye1X, eye1Y), r * 0.25, eyeP);
    canvas.drawCircle(Offset(eye2X, eye2Y), r * 0.25, eyeP);
    
    canvas.drawCircle(Offset(eye1X + dx * 1.5, eye1Y + dy * 1.5), r * 0.12, pupilP);
    canvas.drawCircle(Offset(eye2X + dx * 1.5, eye2Y + dy * 1.5), r * 0.12, pupilP);

    final tx = x + dx * r;
    final ty = y + dy * r;
    canvas.drawLine(Offset(tx, ty), Offset(tx + dx * r * 0.6, ty + dy * r * 0.6), tongueP);
    canvas.drawLine(Offset(tx + dx * r * 0.6, ty + dy * r * 0.6), Offset(tx + dx * r * 0.8 + eOx*0.3, ty + dy * r * 0.8 + eOy*0.3), tongueP);
    canvas.drawLine(Offset(tx + dx * r * 0.6, ty + dy * r * 0.6), Offset(tx + dx * r * 0.8 - eOx*0.3, ty + dy * r * 0.8 - eOy*0.3), tongueP);
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
    for (final food in foods) {
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

      // Little floating particles around food
      for (int i = 0; i < 3; i++) {
        double pA = _pulseT * 3 + (i * pi * 2 / 3);
        double pR = r + 4;
        canvas.drawCircle(Offset(cx + cos(pA)*pR, cy + sin(pA)*pR), 1.5, Paint()..color = foodColor.withOpacity(0.8));
      }

      // Type label
      if (food.type != FoodType.normal) {
        final label = food.type == FoodType.poison ? '☠' : '⚡';
        final tp = TextPainter(text: TextSpan(text: label, style: const TextStyle(fontSize: 9)), textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - r - 11));
      }
    }
  }

  void drawDecorativeSnakes(Canvas canvas) {
    for (final deco in decoSnakes) {
      for (int i = deco.body.length - 1; i >= 0; i--) {
        final pt = deco.body[i];
        final t = i / deco.body.length.clamp(1, 99);
        final c = Color.lerp(deco.color, Colors.black, t)!;
        final r = GameConfig.cellSize / 2.8;

        if (i == 0) {
          canvas.drawCircle(pt, r + 2, Paint()..color = deco.color.withOpacity(0.12)..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4));
        }

        canvas.drawCircle(pt, r, Paint()..color = c.withOpacity(0.35));

        if (i == 0) {
           final eyeP = Paint()..color = Colors.white.withOpacity(0.4);
           canvas.drawCircle(Offset(pt.dx + 2, pt.dy - 2), 1.0, eyeP);
           canvas.drawCircle(Offset(pt.dx + 2, pt.dy + 2), 1.0, eyeP);
        }
      }
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

class DecorativeSnake {
  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double speed = 0;
  Color color = Colors.white;
  List<Offset> body = [];
  int length = 0;
  double _time = 0;

  DecorativeSnake(Random random) {
    x = random.nextDouble() * GameConfig.columns * GameConfig.cellSize;
    y = random.nextDouble() * GameConfig.rows * GameConfig.cellSize;
    
    if (random.nextBool()) {
      vx = random.nextBool() ? 1 : -1; vy = 0;
    } else {
      vx = 0; vy = random.nextBool() ? 1 : -1;
    }
    speed = 25 + random.nextDouble() * 25;
    length = 8 + random.nextInt(8);
    
    final colors = [Colors.yellowAccent, Colors.greenAccent, Colors.redAccent, Colors.purpleAccent, Colors.cyanAccent];
    color = colors[random.nextInt(colors.length)];
  }

  void update(double dt) {
    _time += dt;
    double wave = sin(_time * 3) * 15;
    double rx = x + (vy != 0 ? wave : 0);
    double ry = y + (vx != 0 ? wave : 0);

    if (body.isEmpty || (Offset(rx, ry) - body.first).distance > GameConfig.cellSize * 0.8) {
      body.insert(0, Offset(rx, ry));
      if (body.length > length) body.removeLast();
    }

    x += vx * speed * dt;
    y += vy * speed * dt;

    double maxW = GameConfig.columns * GameConfig.cellSize;
    double maxH = GameConfig.rows * GameConfig.cellSize;
    if (x < -50) x = maxW + 50;
    if (x > maxW + 50) x = -50;
    if (y < -50) y = maxH + 50;
    if (y > maxH + 50) y = -50;
  }
}
