import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/game_state.dart';
import '../../game/snake_hunter_game.dart';
import '../widgets/game_overlay.dart';
import 'package:flame/game.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [GameColors.primary, GameColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Menu Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Title
                Text(
                  'SNAKE HUNTER',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    shadows: [
                      const Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, end: 0),
                
                const SizedBox(height: 10),
                
                Text(
                  'THE MODERN CHASE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 4.0,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                
                const SizedBox(height: 60),
                
                // Play Button
                _MenuButton(
                  text: 'PLAY',
                  onPressed: () {
                    context.read<GameState>().resetGame();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  primary: true,
                ).animate().fadeIn(delay: 800.ms).scale(),
                
                const SizedBox(height: 20),
                
                _MenuButton(
                  text: 'SETTINGS',
                  onPressed: () {
                    // Show settings modal
                  },
                ).animate().fadeIn(delay: 1000.ms).scale(),
                
                const SizedBox(height: 20),
                
                _MenuButton(
                  text: 'LEADERBOARD',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardScreen(),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 1200.ms).scale(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool primary;

  const _MenuButton({
    required this.text,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? GameColors.accent : Colors.white.withOpacity(0.9),
          foregroundColor: primary ? Colors.black87 : GameColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameStyles.borderRadius),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameState>();
    return Scaffold(
      body: GameWidget(
        game: SnakeHunterGame(gameState),
        initialActiveOverlays: const ['HUD'],
        overlayBuilderMap: {
          'HUD': (context, game) => const GameOverlay(),
          'PauseMenu': (context, game) => const Center(child: Text('PAUSED')),
          'GameOver': (context, game) => const GameOverOverlay(),
        },
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.primary,
      appBar: AppBar(
        title: const Text('TOP HUNTERS'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        decoration: GameStyles.glassmorphism,
        child: FutureBuilder<List<int>>(
          future: context.read<GameState>().loadHighScores(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            final scores = snapshot.data!;
            if (scores.isEmpty) {
              return const Center(child: Text('No scores yet!', style: TextStyle(color: Colors.white70)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: scores.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: GameColors.accent,
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                  ),
                  title: Text(
                    '${scores[index]} PTS',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: const Icon(Icons.emoji_events_rounded, color: GameColors.accent),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(30),
        decoration: GameStyles.glassmorphism.copyWith(
          color: Colors.black87.withOpacity(0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SCORE: ${state.score}',
              style: const TextStyle(color: GameColors.accent, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _MenuButton(
              text: 'RETRY',
              onPressed: () {
                state.resetGame();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              primary: true,
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'MENU',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
    );
  }
}
