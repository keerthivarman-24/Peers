import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedHomeScreen extends StatefulWidget {
  const AnimatedHomeScreen({super.key});

  @override
  State<AnimatedHomeScreen> createState() => _AnimatedHomeScreenState();
}

class _AnimatedHomeScreenState extends State<AnimatedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fallController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fallController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Stack(children: [_fallingElements(), _mainContent()]),
    );
  }

  // ---------------- FALLING BACKGROUND ELEMENTS ----------------
  Widget _fallingElements() {
    return AnimatedBuilder(
      animation: _fallController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final random = Random(index);
            final size = random.nextDouble() * 80 + 40;
            final x = random.nextDouble();

            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top:
                  Tween<double>(
                        begin: -150,
                        end:
                            MediaQuery.of(context).size.height *
                            (0.1 + random.nextDouble() * 0.6),
                      )
                      .animate(
                        CurvedAnimation(
                          parent: _fallController,
                          curve: Curves.easeOutCubic,
                        ),
                      )
                      .value,
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, sin(_floatController.value * 2 * pi) * 8),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color.fromARGB(
                              255,
                              14,
                              14,
                              50,
                            ).withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        );
      },
    );
  }

  // ---------------- MAIN CONTENT ----------------
  Widget _mainContent() {
    return Center(
      child: AnimatedBuilder(
        animation: _fallController,
        builder: (context, child) {
          return Opacity(
            opacity: _fallController.value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - _fallController.value)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Ask Freely",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Anonymous doubts • Honest answers",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 50),
                  _ctaButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- CTA BUTTON ----------------
  Widget _ctaButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Text(
          "Ask a Doubt",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
