import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Circular progress ring with gradient effect and smooth animation
/// Optimized for performance with efficient repainting
class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.progress,
    required this.size,
    required this.trackWidth,
    required this.color,
    required this.centerNumber,
    required this.centerSubtitle,
    this.startAngle = -math.pi / 2,
    this.dashSweep = 0,
    this.gapSweep = 0,
    this.gradientColors,
    this.tickCount = 0,
    this.tickLength = 0,
    this.tickWidth = 2,
    this.tickColor,
    this.backgroundColor,
    this.showHeadDot = true,
    this.enableGlowEffect = true,
  });

  final double progress;
  final double size;
  final double trackWidth;
  final Color color;
  final String centerNumber;
  final String centerSubtitle;
  final double startAngle;
  final double dashSweep;
  final double gapSweep;
  final List<Color>? gradientColors;
  final int tickCount;
  final double tickLength;
  final double tickWidth;
  final Color? tickColor;
  final Color? backgroundColor;
  final bool showHeadDot;
  final bool enableGlowEffect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        backgroundColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect layer (optional for better visual)
          if (enableGlowEffect && progress > 0)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          // Main ring painter
          CustomPaint(
            size: Size.square(size),
            painter: _AdvancedRingPainter(
              progress: progress,
              trackWidth: trackWidth,
              color: color,
              backgroundColor: bgColor,
              startAngle: startAngle,
              dashSweep: dashSweep,
              gapSweep: gapSweep,
              gradientColors: gradientColors,
              tickCount: tickCount,
              tickLength: tickLength,
              tickWidth: tickWidth,
              tickColor: tickColor,
            ),
          ),
          // Center texts
          Padding(
            padding: EdgeInsets.symmetric(horizontal: trackWidth * 1.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    centerNumber,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size * 0.20, // smaller base to ensure it fits
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: size * 0.02),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    centerSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          size * 0.09, // Base font size, scales down if needed
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Head dot at end of arc
          if (showHeadDot)
            _RingHeadDot(
              size: size,
              trackWidth: trackWidth,
              progress: progress,
              color: color,
              startAngle: startAngle,
            ),
        ],
      ),
    );
  }
}

class _AdvancedRingPainter extends CustomPainter {
  _AdvancedRingPainter({
    required this.progress,
    required this.trackWidth,
    required this.color,
    required this.backgroundColor,
    required this.startAngle,
    required this.dashSweep,
    required this.gapSweep,
    required this.gradientColors,
    required this.tickCount,
    required this.tickLength,
    required this.tickWidth,
    required this.tickColor,
  });

  final double progress; // 0..1
  final double trackWidth;
  final Color color;
  final Color backgroundColor;
  final double startAngle;
  final double dashSweep;
  final double gapSweep;
  final List<Color>? gradientColors;
  final int tickCount;
  final double tickLength;
  final double tickWidth;
  final Color? tickColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - trackWidth) / 2;

    final trackPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Create gradient shader for smooth color transition
    if (gradientColors != null && gradientColors!.length >= 2) {
      progressPaint.shader = SweepGradient(
        colors: gradientColors!,
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      progressPaint.color = color;
    }

    // Draw background track (dashed or solid)
    if (dashSweep > 0 && gapSweep > 0) {
      const double total = math.pi * 2;
      for (double a = 0; a < total; a += (dashSweep + gapSweep)) {
        final double sweep = math.min(dashSweep, total - a);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + a,
          sweep,
          false,
          trackPaint,
        );
      }
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0,
        math.pi * 2,
        false,
        trackPaint,
      );
    }

    // Draw progress arc with smooth animation
    final double sweep = (math.pi * 2) * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      progressPaint,
    );

    // Draw tick marks if configured
    if (tickCount > 0 && tickLength > 0) {
      final double step = (math.pi * 2) / tickCount;
      final Color tColor = (tickColor ?? color);
      for (int i = 0; i < tickCount; i++) {
        final double a = startAngle + i * step;
        final bool passed = (i / tickCount) <= progress;
        final Paint p = Paint()
          ..color = passed ? tColor : tColor.withValues(alpha: 0.3)
          ..strokeWidth = tickWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        final double innerR = radius - tickLength / 2;
        final double outerR = radius + tickLength / 2;
        final Offset p1 = Offset(
          center.dx + innerR * math.cos(a),
          center.dy + innerR * math.sin(a),
        );
        final Offset p2 = Offset(
          center.dx + outerR * math.cos(a),
          center.dy + outerR * math.sin(a),
        );
        canvas.drawLine(p1, p2, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdvancedRingPainter old) {
    return old.progress != progress ||
        old.trackWidth != trackWidth ||
        old.color != color ||
        old.backgroundColor != backgroundColor ||
        old.startAngle != startAngle ||
        old.dashSweep != dashSweep ||
        old.gapSweep != gapSweep ||
        old.tickCount != tickCount ||
        old.tickLength != tickLength ||
        old.tickWidth != tickWidth ||
        old.tickColor != tickColor ||
        old.gradientColors != gradientColors;
  }
}

class _RingHeadDot extends StatelessWidget {
  const _RingHeadDot({
    required this.size,
    required this.trackWidth,
    required this.progress,
    required this.color,
    required this.startAngle,
  });

  final double size;
  final double trackWidth;
  final double progress;
  final Color color;
  final double startAngle;

  @override
  Widget build(BuildContext context) {
    final angle = startAngle + (math.pi * 2) * progress;
    final radius = (size - trackWidth) / 2;
    final center = Offset(size / 2, size / 2);
    final dotOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    return Positioned(
      left: dotOffset.dx - trackWidth / 2,
      top: dotOffset.dy - trackWidth / 2,
      child: Container(
        width: trackWidth,
        height: trackWidth,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6),
          ],
        ),
      ),
    );
  }
}
