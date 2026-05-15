import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/game_state.dart';
import '../../core/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameOverlay extends StatelessWidget {
  const GameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Score Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: GameStyles.glassmorphism,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SCORE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            '${state.score}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Timer Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: GameStyles.glassmorphism.copyWith(
                        color: state.timeLeft < 10 ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'TIME',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${state.timeLeft}s',
                            style: TextStyle(
                              color: state.timeLeft < 10 ? Colors.redAccent : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate(target: state.timeLeft < 10 ? 1 : 0).shake(),

                    if (state.combo > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: GameColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'COMBO X${state.combo}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ).animate().scale(duration: 200.ms).shake(),
                    
                    // Pause Button
                    IconButton(
                      onPressed: () {
                        // Handle pause
                      },
                      icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white24,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Level Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: GameStyles.glassmorphism,
                  child: Text(
                    'LEVEL ${state.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ).animate(key: ValueKey(state.level)).scale(duration: 400.ms, curve: Curves.elasticOut),
              ],
            ),
          ),
        );
      },
    );
  }
}
