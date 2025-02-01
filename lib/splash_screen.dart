import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'initial_page.dart'; // Import your initial page file

class BallBounceIndex extends StatefulWidget {
  const BallBounceIndex({super.key});

  @override
  State<BallBounceIndex> createState() => _BallBounceIndexState();
}

class _BallBounceIndexState extends State<BallBounceIndex> {
  @override
  void initState() {
    super.initState();
    // Navigate to the initial page after 6 seconds (adjust time if needed)
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const InitialPage(
                  title: 'abc',
                )), // Replace with your initial page widget
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 130),
              child: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 108, 25, 218),
              )
                  .animate()
                  .slideY(begin: -0.5, end: 0.2, duration: 0.5.seconds)
                  .then(delay: 600.milliseconds)
                  .slideY(end: -0.3, duration: 0.5.seconds)
                  .then(delay: 600.milliseconds)
                  .slideY(end: 0.1, duration: 0.5.seconds)
                  .then(delay: 1.seconds)
                  .scaleXY(end: 20, duration: 2.seconds)
                  .then(delay: 2.seconds),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/your_logo.png'), // Replace with your image asset path
                  fit: BoxFit.cover,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 4.seconds, duration: 900.milliseconds)
                .slideX(begin: 3, duration: 0.5.seconds),
          ),
        ],
      ),
    );
  }
}
