import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const StressApp());

class StressApp extends StatelessWidget {
  const StressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StressReliefPage(),
    );
  }
}

class StressReliefPage extends StatefulWidget {
  const StressReliefPage({super.key});

  @override
  State<StressReliefPage> createState() => _StressReliefPageState();
}

class _StressReliefPageState extends State<StressReliefPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> moveAnimation;

  int score = 0;

  // Breathing cycle logic
  int inhale = 4;
  int hold = 2;
  int exhale = 4;
  String phase = "Inhale";
  int currentTimer = 4;

  // Bubble Y position stays constant
  double bubbleY = 350;

  // Speed (bigger = slower)
  int speed = 900; // Very slow initially

  @override
  void initState() {
    super.initState();

    // Breathing animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: speed),
    );

    // Movement Animation (LEFT → RIGHT → LEFT)
    moveAnimation = Tween<double>(begin: 20, end: 300).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);

    breathingCycle();
  }

  void breathingCycle() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        currentTimer--;

        if (currentTimer <= 0) {
          if (phase == "Inhale") {
            phase = "Hold";
            currentTimer = hold;
          } else if (phase == "Hold") {
            phase = "Exhale";
            currentTimer = exhale;
          } else {
            phase = "Inhale";
            currentTimer = inhale;
          }
        }
      });

      return true;
    });
  }

  void updateSpeed() {
    if (score < 25) {
      speed = 900;   // very slow
    } else if (score < 50) {
      speed = 650;   // slow
    } else {
      speed = 450;   // normal
    }

    // Update animation controller with new speed
    _controller.duration = Duration(milliseconds: speed);
    _controller.repeat(reverse: true);
  }

  void popBubble() {
    setState(() {
      score++;
      updateSpeed();
    });
  }

  void resetScore() {
    setState(() {
      score = 0;
      speed = 900;

      _controller.duration = Duration(milliseconds: speed);
      _controller.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: resetScore,
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: Stack(
          children: [
            // ---------------- Always Visible Breathing Timer ----------------
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    phase,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    "$currentTimer s",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Score: $score",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ---------------- Breathing Circle ----------------
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  double size = 150 + (_controller.value * 120);
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),

            // ---------------- Single Moving Bubble (fixed path) ----------------
            AnimatedBuilder(
              animation: moveAnimation,
              builder: (context, child) {
                return Positioned(
                  top: bubbleY,
                  left: moveAnimation.value,
                  child: GestureDetector(
                    onTap: () => popBubble(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
