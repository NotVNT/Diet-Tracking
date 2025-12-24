import 'package:flutter/material.dart';
import '../../common/app_styles.dart';
import '../../common/app_colors.dart';

class HealthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const HealthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF26C6DA), Color(0xFFAB47BC)],
          ).createShader(bounds),
          child: Text(
            title,
            style: AppStyles.heading1.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white, // Required for ShaderMask
              shadows: [
                const Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black12,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            subtitle,
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.grey800,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
