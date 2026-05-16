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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── TOP ROW ────────────────────────────────────────
                Row(
                  children: [
                    // Score - Modern glassmorphism
                    _HudCard(
                      icon: '🏆',
                      label: 'SCORE',
                      value: '${state.score}',
                      valueColor: const Color(0xFFFFF176),
                    ),
                    const SizedBox(width: 8),
                    // Level
                    _HudCard(
                      icon: '⭐',
                      label: 'LEVEL',
                      value: '${state.level}',
                      valueColor: const Color(0xFFA5D6A7),
                    ).animate(key: ValueKey(state.level))
                        .scale(duration: 400.ms, curve: Curves.elasticOut),
                    const Spacer(),
                    // Combo (visible only when active)
                    if (state.combo > 1)
                      _ComboChip(combo: state.combo)
                          .animate()
                          .scale(duration: 200.ms, curve: Curves.easeOutBack)
                          .shake(duration: 150.ms),
                    const SizedBox(width: 8),
                    // Timer
                    _TimerCard(timeLeft: state.timeLeft),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── HUD Sub-Widgets ─────────────────────────────────────────────────────────

class _HudCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color valueColor;

  const _HudCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xCC1B5E20).withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x88FFFFFF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xAA9EFFD1),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  final int timeLeft;
  const _TimerCard({required this.timeLeft});

  @override
  Widget build(BuildContext context) {
    final isUrgent = timeLeft < 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xCCB71C1C) : const Color(0xCC1B2E1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? const Color(0xCCFF4757) : const Color(0x662ECC71),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isUrgent
                ? const Color(0x88FF4757)
                : const Color(0x882ECC71),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TIME',
            style: TextStyle(
              color: Color(0xAA9EFFD1),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            '${timeLeft}s',
            style: TextStyle(
              color: isUrgent ? Colors.red.shade300 : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    ).animate(target: isUrgent ? 1 : 0).shake(duration: 400.ms);
  }
}

class _ComboChip extends StatelessWidget {
  final int combo;
  const _ComboChip({required this.combo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: GameStyles.comboPanel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            'x$combo',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              shadows: [Shadow(blurRadius: 4, color: Colors.orange)],
            ),
          ),
        ],
      ),
    );
  }
}
