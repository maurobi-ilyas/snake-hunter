import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000),
              Color(0xFF041B15),
              Color(0xFF092E24),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Title
              _NeonTitle()
                  .animate()
                  .fadeIn(duration: 700.ms)
                  .slideY(begin: -0.3, end: 0),

              const Spacer(),

              // Menu buttons
              _NeonMenuButton(
                label: '▶  PLAY',
                color: const Color(0xFF00FF9D),
                delay: 200,
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const GameScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _NeonMenuButton(
                label: '⚙  SETTINGS',
                color: const Color(0xFF00BFFF),
                delay: 350,
                onTap: () {},
              ),

              const SizedBox(height: 16),

              _NeonMenuButton(
                label: '🏆  LEADERBOARD',
                color: const Color(0xFFFFD700),
                delay: 500,
                onTap: () {},
              ),

              const Spacer(),

              // Version tag
              Text(
                'v1.0.0  •  SNAKE ESCAPE EVOLUTION',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeonTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Snake icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00FF9D).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF9D).withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.linear_scale_rounded,
            size: 52,
            color: Color(0xFF00FF9D),
          ),
        ),
        const SizedBox(height: 24),

        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FF9D), Color(0xFF00C97B)],
          ).createShader(bounds),
          child: const Text(
            'SNAKE ESCAPE',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'E V O L U T I O N',
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF00FF9D).withOpacity(0.5),
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }
}

class _NeonMenuButton extends StatefulWidget {
  final String label;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _NeonMenuButton({
    required this.label,
    required this.color,
    required this.delay,
    required this.onTap,
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
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 260,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.color.withOpacity(_pressed ? 1.0 : 0.6),
            width: 1.5,
          ),
          color: widget.color.withOpacity(_pressed ? 0.2 : 0.06),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_pressed ? 0.5 : 0.15),
              blurRadius: _pressed ? 20 : 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.delay)).slideX(
          begin: -0.1,
          end: 0,
          delay: Duration(milliseconds: widget.delay),
        );
  }
}
