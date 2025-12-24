import 'package:flutter/material.dart';

class HealthBackground extends StatelessWidget {
  final Widget child;

  const HealthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            child: Icon(Icons.local_pizza,
                size: 120, color: Colors.orange.withOpacity(0.2)),
          ),
        ),
        Positioned(
          bottom: 200,
          right: -30,
          child: Transform.rotate(
            angle: 0.5,
            child: Icon(Icons.icecream,
                size: 100, color: Colors.pink.withOpacity(0.2)),
          ),
        ),
        Positioned(
          bottom: 50,
          right: 40,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(Icons.bakery_dining,
                size: 80, color: Colors.brown.withOpacity(0.2)),
          ),
        ),
        Positioned(
          top: 150,
          left: 20,
          child: Icon(Icons.eco,
              size: 60, color: Colors.green.withOpacity(0.1)),
        ),
        // Content
        child,
      ],
    );
  }
}
