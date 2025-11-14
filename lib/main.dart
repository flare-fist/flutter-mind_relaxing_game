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

  // Quotes that appear when bubble is clicked
  final List<String> quotes = [
    "Stay Calm 🌿",
    "You're Doing Great ✨",
    "Breathe & Relax 💙",
    "Focus on Peace 🌸",
    "One Step at a Time 🌼",
    "You Got This 🌟",
    "Slow Down & Smile 🙂",
  ];
  String currentQuote = "Welcome 👋";

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

    _controller.duration = Duration(milliseconds: speed);
    _controller.repeat(reverse: true);
  }

  void popBubble() {
    setState(() {
      score++;

      // change quote every tap
      currentQuote = quotes[Random().nextInt(quotes.length)];

      updateSpeed();
    });
  }

  void resetScore() {
    setState(() {
      score = 0;
      speed = 900;
      currentQuote = "Stay Relaxed 🌿";

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
            // -------- POSITIVE QUOTE AT TOP --------
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    currentQuote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Score: $score",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),

            // -------- BREATHING CIRCLE WITH PHASE INSIDE --------
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            phase,
                            style: const TextStyle(
                              fontSize: 26,
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // -------- SINGLE MOVING BUBBLE (FIXED PATH) --------
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
                        color: Colors.white.withOpacity(0.9),
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
