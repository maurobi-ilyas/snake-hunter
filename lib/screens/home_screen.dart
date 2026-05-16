import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _coins = 0;
  int _menuIndex = 0;

  late final AnimationController _bgController;
  late final FixedExtentScrollController _scrollController;

  final List<Map<String, dynamic>> _menus = [
    {'label': 'PLAY', 'icon': Icons.play_arrow_rounded, 'color': const Color(0xFF00FF9D), 'screen': const GameScreen()},
    {'label': 'SHOP', 'icon': Icons.shopping_cart_rounded, 'color': const Color(0xFF00BFFF), 'screen': const ShopScreen()},
    {'label': 'LEADERBOARD', 'icon': Icons.emoji_events_rounded, 'color': const Color(0xFFFFD700), 'screen': const LeaderboardScreen()},
    {'label': 'ACHIEVEMENT', 'icon': Icons.military_tech_rounded, 'color': Colors.purpleAccent, 'screen': const AchievementScreen()},
    {'label': 'MISSIONS', 'icon': Icons.track_changes_rounded, 'color': Colors.cyanAccent, 'screen': const MissionScreen()},
    {'label': 'SETTINGS', 'icon': Icons.settings_rounded, 'color': Colors.white54, 'screen': const SettingsScreen()},
  ];

  @override
  void initState() {
    super.initState();
    _coins = LocalStorageService.getCoins();
    if (LocalStorageService.getMusicEnabled()) {
      AudioService.playMenuMusic();
    }
    _checkDailyReward();

    _scrollController = FixedExtentScrollController(initialItem: 0);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _scrollController.dispose();
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
              const Text('DAILY REWARD!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text('+$reward Coins', style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold)),
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
                  child: const Text('CLAIM', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 3)),
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
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) {
      setState(() => _coins = LocalStorageService.getCoins());
    });
  }

  void _nextMenu() {
    setState(() {
      _menuIndex = (_menuIndex + 1) % _menus.length;
    });
  }

  void _prevMenu() {
    setState(() {
      _menuIndex = (_menuIndex - 1 < 0) ? _menus.length - 1 : _menuIndex - 1;
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
        child: Stack(
          children: [
            // Animated Particles & Snake
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _HomeBackgroundPainter(_bgController.value),
                );
              },
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Coin Bar
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
                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms),

                  const Spacer(flex: 2),

                  // Title
                  _NeonTitle().animate().fadeIn(duration: 700.ms).slideY(begin: -0.3, end: 0),

                  const Spacer(flex: 3),

                  // Cool Scrolling Menu
                  SizedBox(
                    height: 280,
                    child: ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 90,
                      diameterRatio: 2.0,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _menuIndex = index);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final isSelected = _menuIndex == index;
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            tween: Tween(begin: 0.8, end: isSelected ? 1.0 : 0.85),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: isSelected ? 1.0 : 0.4,
                                  child: child,
                                ),
                              );
                            },
                            child: _NeonMenuButton(
                              label: _menus[index]['label'],
                              icon: _menus[index]['icon'],
                              color: _menus[index]['color'],
                              onTap: () {
                                if (_menuIndex == index) {
                                  _navigate(_menus[index]['screen']);
                                } else {
                                  _scrollController.animateToItem(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          );
                        },
                        childCount: _menus.length,
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 500.ms),

                  const Spacer(flex: 3),

                  Text(
                    'v1.0.0  •  SNAKE ESCAPE EVOLUTION',
                    style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, letterSpacing: 2),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BACKGROUND PAINTER (SNAKE & PARTICLES) ──────────────

class _HomeBackgroundPainter extends CustomPainter {
  final double progress;
  _HomeBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    _drawParticles(canvas, size);
    _drawAnimatedSnake(canvas, size);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final rand = Random(42);
    final paint = Paint()..color = Colors.white.withOpacity(0.15);
    for (int i = 0; i < 30; i++) {
      double x = (rand.nextDouble() * size.width + progress * size.width * (rand.nextDouble() * 0.5 + 0.1)) % size.width;
      double y = rand.nextDouble() * size.height;
      double r = rand.nextDouble() * 2 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _drawAnimatedSnake(Canvas canvas, Size size) {
    // 1. Main Snake (Green, Left to Right, Bottom)
    _drawSingleSnake(canvas, size, progress, 15, 0.75, 1.0, const Color(0xFF00FF9D), const Color(0xFF1B5E20));
    // 2. Secondary Snake (Cyan, Right to Left, Top)
    _drawSingleSnake(canvas, size, (progress + 0.4) % 1.0, 10, 0.15, -0.8, Colors.cyanAccent, const Color(0xFF006064));
    // 3. Fast Snake (Purple, Left to Right, Middle)
    _drawSingleSnake(canvas, size, (progress * 1.5) % 1.0, 8, 0.45, 1.5, Colors.purpleAccent, const Color(0xFF4A148C));
    // 4. Slow Snake (Amber, Right to Left, Lower Middle)
    _drawSingleSnake(canvas, size, (progress * 0.6 + 0.2) % 1.0, 18, 0.6, -0.5, Colors.amber, const Color(0xFF7B4F00));
  }

  void _drawSingleSnake(Canvas canvas, Size size, double p, int snakeLength, double yRatio, double speedDir, Color skinColor, Color darkColor) {
    final double spacing = 18.0;
    final double radius = 8.0 + (speedDir.abs() * 2); // Faster/main snakes are slightly thicker

    double totalTravel = size.width + snakeLength * spacing * 3;
    double headX;
    if (speedDir > 0) {
      headX = (p * totalTravel) - (snakeLength * spacing * 2);
    } else {
      headX = size.width + (snakeLength * spacing * 2) - (p * totalTravel);
    }

    double baseY = size.height * yRatio;

    for (int i = snakeLength - 1; i >= 0; i--) {
      double t = i / snakeLength;
      Color color = Color.lerp(skinColor, darkColor, t)!;

      // Wave motion
      double waveOffset = sin((progress * pi * 8) - (i * 0.4)) * (10 + speedDir.abs() * 5);
      
      double x;
      if (speedDir > 0) {
        x = headX - (i * spacing);
      } else {
        x = headX + (i * spacing);
      }
      
      double y = baseY + waveOffset;

      if (i == 0) {
        // Head glow
        canvas.drawCircle(Offset(x, y), radius + 4,
          Paint()..color = skinColor.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8));
      }

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..shader = RadialGradient(colors: [skinColor, color]).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius))
          ..color = color.withOpacity(0.7),
      );

      // Draw eyes and tongue on the head
      if (i == 0) {
        final eyeP = Paint()..color = Colors.white.withOpacity(0.8);
        final pupilP = Paint()..color = Colors.black;
        final tongueP = Paint()..color = Colors.redAccent.withOpacity(0.8)..strokeWidth = 1.5;

        double eOx = speedDir > 0 ? 0 : 0;
        double eOy = radius * 0.4;

        final eye1X = speedDir > 0 ? (x + radius * 0.3) : (x - radius * 0.3);
        final eye1Y = y + radius * 0.3 + eOy;
        final eye2X = speedDir > 0 ? (x + radius * 0.3) : (x - radius * 0.3);
        final eye2Y = y - radius * 0.3 - eOy;

        canvas.drawCircle(Offset(eye1X, eye1Y), radius * 0.3, eyeP);
        canvas.drawCircle(Offset(eye2X, eye2Y), radius * 0.3, eyeP);

        final pOffset = speedDir > 0 ? 1.5 : -1.5;
        canvas.drawCircle(Offset(eye1X + pOffset, eye1Y), radius * 0.15, pupilP);
        canvas.drawCircle(Offset(eye2X + pOffset, eye2Y), radius * 0.15, pupilP);

        // Tongue
        final tx = speedDir > 0 ? (x + radius) : (x - radius);
        final ty = y;
        final tDir = speedDir > 0 ? 1 : -1;
        
        canvas.drawLine(Offset(tx, ty), Offset(tx + radius * 0.6 * tDir, ty), tongueP);
        canvas.drawLine(Offset(tx + radius * 0.6 * tDir, ty), Offset(tx + radius * 0.8 * tDir, ty + radius * 0.3), tongueP);
        canvas.drawLine(Offset(tx + radius * 0.6 * tDir, ty), Offset(tx + radius * 0.8 * tDir, ty - radius * 0.3), tongueP);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
          child: Text('SNAKE ESCAPE',
              style: GoogleFonts.orbitron(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 5)),
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
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NeonMenuButton({
    super.key, required this.label, required this.icon, required this.color, required this.onTap,
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
        duration: const Duration(milliseconds: 150),
        width: 280,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color.withOpacity(_pressed ? 1.0 : 0.6), width: 2),
          color: widget.color.withOpacity(_pressed ? 0.25 : 0.08),
          boxShadow: [
            BoxShadow(color: widget.color.withOpacity(_pressed ? 0.5 : 0.2), blurRadius: _pressed ? 25 : 12, spreadRadius: 2)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 28),
            const SizedBox(width: 16),
            Text(widget.label,
                style: TextStyle(color: widget.color, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3)),
          ],
        ),
      ),
    );
  }
}
