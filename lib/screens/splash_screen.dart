import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF0B2B26),
              Color(0xFF071A12),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Particle dots background
            ..._buildParticles(),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Snake icon with glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF9D).withOpacity(
                              0.3 + _pulseController.value * 0.4,
                            ),
                            blurRadius: 40 + _pulseController.value * 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.linear_scale_rounded,
                        size: 80,
                        color: Color(0xFF00FF9D),
                      ),
                    ),
                  ).animate().scale(
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 40),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00FF9D), Color(0xFF00C97B)],
                    ).createShader(bounds),
                    child: const Text(
                      'SNAKE ESCAPE',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  ).animate().fadeIn(duration: 900.ms, delay: 300.ms).slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 700.ms,
                        delay: 300.ms,
                      ),

                  const SizedBox(height: 8),

                  Text(
                    'EVOLUTION',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF00FF9D).withOpacity(0.6),
                      letterSpacing: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

                  const SizedBox(height: 60),

                  // Loading bar
                  SizedBox(
                    width: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF00FF9D),
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    final rng = Random(42);
    return List.generate(20, (i) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      final size = rng.nextDouble() * 3 + 1;
      return Positioned(
        left: MediaQuery.of(context).size.width * x,
        top: MediaQuery.of(context).size.height * y,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00FF9D).withOpacity(0.2 + rng.nextDouble() * 0.3),
          ),
        ).animate(
          onPlay: (c) => c.repeat(reverse: true),
        ).fadeIn(
          duration: Duration(milliseconds: 800 + rng.nextInt(1200)),
          delay: Duration(milliseconds: rng.nextInt(1500)),
        ),
      );
    });
  }
}
