import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';

/// An animated horizontal arrow pointing to the floating action button.
///
/// Features:
/// - Smooth horizontal animation
/// - Optional glow for better contrast on light backgrounds
/// - Customizable color and size
/// - Responsive design
class AnimatedArrowPointer extends StatefulWidget {
  final Color? color;
  final double? size;
  final Duration animationDuration;
  final bool glow; // add subtle glow for visibility

  const AnimatedArrowPointer({
    super.key,
    this.color,
    this.size,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.glow = true,
  });

  @override
  State<AnimatedArrowPointer> createState() => _AnimatedArrowPointerState();
}

class _AnimatedArrowPointerState extends State<AnimatedArrowPointer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final size = widget.size ?? responsive.width(48);
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: CustomPaint(
            size: Size(size, size * 0.6),
            painter: _ArrowPainter(color: color, glow: widget.glow),
          ),
        );
      },
    );
  }
}

/// Custom painter for drawing a horizontal arrow
class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool glow;

  _ArrowPainter({required this.color, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.1;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = stroke * 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final height = size.height;
    final width = size.width;

    // Draw glow first for better contrast
    if (glow) {
      canvas.drawLine(Offset(0, height / 2), Offset(width * 0.7, height / 2), glowPaint);
      final glowHead = Path()
        ..moveTo(width * 0.65, height * 0.15)
        ..lineTo(width, height / 2)
        ..lineTo(width * 0.65, height * 0.85);
      canvas.drawPath(glowHead, glowPaint);
    }

    // Arrow shaft (horizontal line)
    canvas.drawLine(
      Offset(0, height / 2),
      Offset(width * 0.7, height / 2),
      paint,
    );

    // Arrow head (right-pointing triangle)
    final path = Path();
    path.moveTo(width * 0.65, height * 0.15); // Top point
    path.lineTo(width, height / 2); // Right point
    path.lineTo(width * 0.65, height * 0.85); // Bottom point
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.glow != glow;
}

