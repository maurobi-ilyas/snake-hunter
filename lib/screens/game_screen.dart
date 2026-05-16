import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/engine/snake_game.dart';
import '../game/models/direction.dart';
import '../core/services/audio_service.dart';
import '../core/services/local_storage_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnakeGame game;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    game = SnakeGame();
    if (LocalStorageService.getMusicEnabled()) {
      AudioService.playGameMusic();
    }
  }

  @override
  void dispose() {
    if (LocalStorageService.getMusicEnabled()) {
      AudioService.playMenuMusic(); // Switch back to menu music
    }
    super.dispose();
  }

  void handleSwipeUpdate(DragUpdateDetails details) {
    if (details.delta.distance < 2.5) return; // Sensitivity threshold
    final dx = details.delta.dx;
    final dy = details.delta.dy;
    if (dx.abs() > dy.abs()) {
      game.queueDirection(dx > 0 ? Direction.right : Direction.left);
    } else {
      game.queueDirection(dy > 0 ? Direction.down : Direction.up);
    }
  }

  void _togglePause() {
    if (game.isGameOver) return;
    setState(() {
      if (_isPaused) {
        game.startGameLoop();
        _isPaused = false;
      } else {
        game.gameTimer?.cancel();
        _isPaused = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050816),
        elevation: 0,
        title: const Text('SNAKE ESCAPE', style: TextStyle(fontSize: 14, letterSpacing: 3)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            game.gameTimer?.cancel();
            Navigator.pop(context);
          },
        ),
        actions: [
          // Stage notifier
          ValueListenableBuilder<int>(
            valueListenable: game.stageNotifier,
            builder: (_, stage, __) => Center(
              child: Text('S$stage',
                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
          const SizedBox(width: 4),
          // Level
          ValueListenableBuilder<int>(
            valueListenable: game.levelNotifier,
            builder: (_, lv, __) => Center(
              child: Text('LV$lv',
                  style: const TextStyle(color: Colors.yellowAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 6),
          // Pause button
          IconButton(
            onPressed: _togglePause,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isPaused ? Icons.play_circle_outline : Icons.pause_circle_outline,
                key: ValueKey(_isPaused),
                color: const Color(0xFF00FF9D),
                size: 22,
              ),
            ),
          ),
          // Score
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: game.scoreNotifier,
                builder: (_, score, __) => Text('$score',
                    style: const TextStyle(color: Color(0xFF00FF9D), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Game area
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onPanUpdate: handleSwipeUpdate,
                  onTap: () {
                    // Tap to restart when game over
                    if (game.isGameOver) setState(() => game.restartGame());
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00FF9D).withOpacity(0.35), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00FF9D).withOpacity(0.10), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: GameWidget(game: game),
                    ),
                  ),
                ),
              ),

              // Bottom action bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 2, 24, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      label: 'RESTART',
                      icon: Icons.refresh_rounded,
                      color: const Color(0xFF00FF9D),
                      onTap: () => setState(() => game.restartGame()),
                    ),
                    // Coins live display
                    ValueListenableBuilder<int>(
                      valueListenable: game.coinsNotifier,
                      builder: (_, coins, __) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('$coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                    _ActionButton(
                      label: 'MENU',
                      icon: Icons.home_rounded,
                      color: Colors.white54,
                      onTap: () { game.gameTimer?.cancel(); Navigator.pop(context); },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── PAUSE OVERLAY ────────────────────────────────────
          if (_isPaused)
            GestureDetector(
              onTap: _togglePause,
              child: Container(
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFF0D1117),
                          border: Border.all(color: const Color(0xFF00FF9D).withOpacity(0.4), width: 1.5),
                          boxShadow: [BoxShadow(color: const Color(0xFF00FF9D).withOpacity(0.2), blurRadius: 30)],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.pause_circle_filled, size: 52, color: Color(0xFF00FF9D)),
                            const SizedBox(height: 12),
                            const Text('PAUSED',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 6)),
                            const SizedBox(height: 8),
                            Text('Tap anywhere to resume',
                                style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
          color: color.withOpacity(0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}
