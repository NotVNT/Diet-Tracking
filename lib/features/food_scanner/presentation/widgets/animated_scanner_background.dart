import 'package:flutter/material.dart';

/// Animated gradient background shown behind scanner previews.
class AnimatedScannerBackground extends StatefulWidget {
  const AnimatedScannerBackground({super.key});

  @override
  State<AnimatedScannerBackground> createState() => _AnimatedScannerBackgroundState();
}

class _AnimatedScannerBackgroundState extends State<AnimatedScannerBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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
      builder: (context, _) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF383838),
                Color.lerp(const Color(0xFF383838), Colors.black, t * 0.7)!,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
