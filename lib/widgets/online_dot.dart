import 'package:flutter/material.dart';

class OnlineDot extends StatefulWidget {
  const OnlineDot({super.key});

  @override
  State<OnlineDot> createState() => _OnlineDotState();
}

class _OnlineDotState extends State<OnlineDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final scale = 1.0 + 0.25 * _controller.value;
        final opacity = 0.6 + 0.4 * _controller.value;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF34D399), // emerald green
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34D399).withOpacity(0.6),
                    blurRadius: 8 * _controller.value,
                    spreadRadius: 1.5 * _controller.value,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
