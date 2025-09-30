import 'package:flutter/widgets.dart';

/// Simple responsive helper tuned for the weight screens
class WeightResponsive {
  final double width;
  final double height;

  WeightResponsive._(this.width, this.height);

  /// Create from BuildContext
  static WeightResponsive of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WeightResponsive._(size.width, size.height);
  }

  /// Base on iPhone 12 width 390
  double get scale {
    final s = width / 390.0;
    if (s < 0.8) return 0.8; // avoid too small
    if (s > 1.3) return 1.3; // avoid too big
    return s;
  }

  double font(double base) => (base * scale).clamp(base * 0.85, base * 1.2);
  double space(double base) => (base * scale).clamp(base * 0.8, base * 1.3);
  double radius(double base) => (base * scale).clamp(base * 0.8, base * 1.3);
}
