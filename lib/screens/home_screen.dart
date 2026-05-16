import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/services/audio_service.dart';
import '../core/services/daily_reward_service.dart';
import '../core/services/local_storage_service.dart';
import 'achievement_screen.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'mission_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _coins = LocalStorageService.getCoins();
    if (LocalStorageService.getMusicEnabled()) {
      AudioService.playBackgroundMusic();
    }
    _checkDailyReward();
  }

  @override
  void dispose() {
    AudioService.stopMusic();
    super.dispose();
  }

  Future<void> _checkDailyReward() async {
    if (!DailyRewardService.canClaimReward()) return;

    final reward = await DailyRewardService.claimReward();
    await LocalStorageService.addCoins(reward);

    if (mounted) {
      setState(() => _coins = LocalStorageService.getCoins());
      _showDailyRewardDialog(reward);
    }
  }

  void _showDailyRewardDialog(int reward) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0D1117),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.card_giftcard, size: 56, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'DAILY REWARD!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '+$reward Coins',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.amber.withOpacity(0.15),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: const Text(
                    'CLAIM',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) {
      // Refresh coins when returning from shop
      setState(() => _coins = LocalStorageService.getCoins());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF041B15), Color(0xFF092E24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Coin bar top right
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, top: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_coins',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 16),

              // Title
              _NeonTitle().animate().fadeIn(duration: 700.ms).slideY(begin: -0.3, end: 0),

              const Spacer(),

              // Menu buttons
              _NeonMenuButton(label: '▶  PLAY',         color: const Color(0xFF00FF9D), delay: 200, onTap: () => _navigate(const GameScreen())),
              const SizedBox(height: 14),
              _NeonMenuButton(label: '🛒  SHOP',         color: const Color(0xFF00BFFF), delay: 300, onTap: () => _navigate(const ShopScreen())),
              const SizedBox(height: 14),
              _NeonMenuButton(label: '🏆  LEADERBOARD',  color: const Color(0xFFFFD700), delay: 400, onTap: () => _navigate(const LeaderboardScreen())),
              const SizedBox(height: 14),
              _NeonMenuButton(label: '🎖  ACHIEVEMENT',  color: Colors.purpleAccent,     delay: 500, onTap: () => _navigate(const AchievementScreen())),
              const SizedBox(height: 14),
              _NeonMenuButton(label: '🎯  MISSIONS',     color: Colors.cyanAccent,       delay: 600, onTap: () => _navigate(const MissionScreen())),
              const SizedBox(height: 14),
              _NeonMenuButton(label: '⚙  SETTINGS',     color: Colors.white54,          delay: 700, onTap: () => _navigate(const SettingsScreen())),

              const Spacer(),

              Text(
                'v1.0.0  •  SNAKE ESCAPE EVOLUTION',
                style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, letterSpacing: 2),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TITLE ─────────────────────────────────────────────────

class _NeonTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00FF9D).withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0xFF00FF9D).withOpacity(0.2), blurRadius: 30, spreadRadius: 5)],
          ),
          child: const Icon(Icons.linear_scale_rounded, size: 48, color: Color(0xFF00FF9D)),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FF9D), Color(0xFF00C97B)],
          ).createShader(bounds),
          child: const Text('SNAKE ESCAPE',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 5)),
        ),
        const SizedBox(height: 4),
        Text('E V O L U T I O N',
            style: TextStyle(fontSize: 10, color: const Color(0xFF00FF9D).withOpacity(0.5), letterSpacing: 8)),
      ],
    );
  }
}

// ─── BUTTON ─────────────────────────────────────────────────

class _NeonMenuButton extends StatefulWidget {
  final String label;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _NeonMenuButton({
    required this.label, required this.color, required this.delay, required this.onTap,
  });

  @override
  State<_NeonMenuButton> createState() => _NeonMenuButtonState();
}

class _NeonMenuButtonState extends State<_NeonMenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 240,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.color.withOpacity(_pressed ? 1.0 : 0.5), width: 1.5),
          color: widget.color.withOpacity(_pressed ? 0.18 : 0.05),
          boxShadow: [BoxShadow(color: widget.color.withOpacity(_pressed ? 0.4 : 0.1), blurRadius: _pressed ? 18 : 8)],
        ),
        child: Center(
          child: Text(widget.label,
              style: TextStyle(color: widget.color, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.delay)).slideX(begin: -0.08, end: 0, delay: Duration(milliseconds: widget.delay));
  }
}
