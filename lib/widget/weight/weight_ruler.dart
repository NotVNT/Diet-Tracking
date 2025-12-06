import 'package:flutter/material.dart';

/// Horizontal ruler slider for weight with 0.5 step in kg
class WeightRuler extends StatelessWidget {
  final double min;
  final double max;
  final double value; // in kg
  final ValueChanged<double> onChanged;
  final Color accent;
  final bool isKg;

  const WeightRuler({
    super.key,
    this.min = 20,
    this.max = 240,
    required this.value,
    required this.onChanged,
    this.accent = const Color(0xFF8B5CF6),
    this.isKg = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.5,
            activeTrackColor: accent,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: accent,
            overlayColor: accent.withValues(alpha: 0.08),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
          ),
          child: Slider(
            min: min,
            max: max,
            divisions: ((max - min) * 2).round(), // 0.5 step
            value: value.clamp(min, max),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          height: 32,
          child: CustomPaint(
            painter: _WeightTicksPainter(min: min, max: max, isKg: isKg),
            size: const Size(double.infinity, 32),
          ),
        ),
      ],
    );
  }
}

class _WeightTicksPainter extends CustomPainter {
  final double min;
  final double max;
  final bool isKg;
  _WeightTicksPainter({
    required this.min,
    required this.max,
    required this.isKg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Baseline
    final basePaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      basePaint,
    );

    final tickPaintMinor = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.0;
    final tickPaintMedium = Paint()
      ..color = const Color(0xFFBFC5CE)
      ..strokeWidth = 1.2;
    final tickPaintMajor = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1.6;

    final total = (max - min).toInt();
    const double lrPadding = 12; // avoid cutoff on edges
    for (int i = 0; i <= total; i++) {
      final x = lrPadding + i / (max - min) * (size.width - lrPadding * 2);
      final isMajor = i % 20 == 0; // every 20 units show label
      final isMedium = i % 10 == 0;
      final isMinor = i % 5 == 0;
      final double height = isMajor
          ? 14.0
          : isMedium
          ? 10.0
          : isMinor
          ? 7.0
          : 0.0;
      if (height == 0.0) continue; // draw every 5 units only
      final paint = isMajor
          ? tickPaintMajor
          : isMedium
          ? tickPaintMedium
          : tickPaintMinor;
      canvas.drawLine(
        Offset(x, size.height - height),
        Offset(x, size.height),
        paint,
      );

      // Draw labels for major ticks only
      if (isMajor) {
        final valueKg = min + i;
        final label = isKg
            ? valueKg.toStringAsFixed(0)
            : (valueKg * 2.2046226218).round().toString();
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
