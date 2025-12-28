import 'package:flutter/material.dart';

class HealthBackground extends StatelessWidget {
  final Widget child;

  const HealthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _BackgroundDecoration(),
        // Content
        child,
      ],
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F7FA), // Light Cyan
                  Color(0xFFFFF3E0), // Light Orange
                  Color(0xFFFFE0B2), // Orange
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // Decorative Icons (Background)
          Positioned(
            bottom: 100,
            left: -20,
            child: Transform.rotate(
              angle: -0.5,
              child: const Icon(
                Icons.local_pizza,
                size: 120,
                color: Color(0x33FF9800), // Colors.orange.withValues(alpha: 0.2)
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -30,
            child: Transform.rotate(
              angle: 0.5,
              child: const Icon(
                Icons.icecream,
                size: 100,
                color: Color(0x33E91E63), // Colors.pink.withValues(alpha: 0.2)
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 40,
            child: Transform.rotate(
              angle: -0.2,
              // FIXED: Added const here
              child: const Icon(
                Icons.bakery_dining,
                size: 80,
                color: Color(0x33795548), // Colors.brown.withValues(alpha: 0.2)
              ),
            ),
          ),
          const Positioned(
            top: 150,
            left: 20,
            // FIXED: Added const here (and wrapped Positioned in const as well since children are const)
            child: Icon(
              Icons.eco,
              size: 60,
              color: Color(0x1A4CAF50), // Colors.green.withValues(alpha: 0.1)
            ),
          ),
        ],
      ),
    );
  }
}