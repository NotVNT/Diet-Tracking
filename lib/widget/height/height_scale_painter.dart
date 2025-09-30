import 'package:flutter/material.dart';

class HeightScalePainter extends CustomPainter {
  final double selectedHeight;
  final double minHeight;
  final double maxHeight;
  final bool isCm;
  final double indicatorLength;

  HeightScalePainter({
    required this.selectedHeight,
    this.minHeight = 120,
    this.maxHeight = 220,
    this.isCm = true,
    this.indicatorLength = 64,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ticks with stronger contrast and thickness
    final minorTickPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2.0;
    final mediumTickPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2.5;
    final majorTickPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 3.0;

    final selectedPaint = Paint()
      ..color =
          const Color(0xFF8B5CF6) // Purple color like in the image
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    final selectedGlowPaint = Paint()
      ..color = const Color(0x338B5CF6)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    // Draw vertical ruler lines
    if (isCm) {
      final startValue = minHeight;
      final endValue = maxHeight;
      final totalSteps = (endValue - startValue).toInt();
      for (int i = 0; i <= totalSteps; i++) {
        final value = startValue + i; // cm
        final y =
            size.height -
            ((value - startValue) / (endValue - startValue) * size.height);
        final isMajor = i % 5 == 0; // every 5 cm
        if (isMajor) {
          canvas.drawLine(Offset(0, y), Offset(25, y), majorTickPaint);

          final textPainter = TextPainter(
            text: TextSpan(
              text: value.toInt().toString(),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(30, y - textPainter.height / 2));
        } else {
          canvas.drawLine(Offset(0, y), Offset(15, y), minorTickPaint);
        }
      }
    } else {
      // Feet mode: 0.1 ft steps, major 1.0 ft, medium 0.5 ft
      final startFt = minHeight / 30.48;
      final endFt = maxHeight / 30.48;
      const stepFt = 0.1;
      final totalSteps = ((endFt - startFt) / stepFt).round();
      for (int i = 0; i <= totalSteps; i++) {
        final valueFt = startFt + i * stepFt;
        final y =
            size.height -
            ((valueFt - startFt) / (endFt - startFt) * size.height);

        final isFullFoot = i % 10 == 0; // 1.0 ft
        final isHalfFoot = i % 5 == 0; // 0.5 ft

        if (isFullFoot) {
          canvas.drawLine(Offset(0, y), Offset(25, y), majorTickPaint);
          final textPainter = TextPainter(
            text: TextSpan(
              text: valueFt.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(30, y - textPainter.height / 2));
        } else if (isHalfFoot) {
          canvas.drawLine(Offset(0, y), Offset(20, y), mediumTickPaint);
        } else {
          canvas.drawLine(Offset(0, y), Offset(12, y), minorTickPaint);
        }
      }
    }

    // Draw selected height indicator
    // Compute selection position in current unit scale
    final startOnScale = isCm ? minHeight : (minHeight / 30.48);
    final endOnScale = isCm ? maxHeight : (maxHeight / 30.48);
    final selectedOnScale = isCm ? selectedHeight : (selectedHeight / 30.48);
    final selectedY =
        size.height -
        ((selectedOnScale - startOnScale) /
            (endOnScale - startOnScale) *
            size.height);

    // Draw purple horizontal line (longer with soft glow)
    canvas.drawLine(
      Offset(0, selectedY),
      Offset(indicatorLength, selectedY),
      selectedGlowPaint,
    );
    canvas.drawLine(
      Offset(0, selectedY),
      Offset(indicatorLength, selectedY),
      selectedPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
