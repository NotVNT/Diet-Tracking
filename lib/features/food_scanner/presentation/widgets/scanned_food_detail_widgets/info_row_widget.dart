import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';

/// Widget to display an information row with icon, label, and value
class InfoRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ResponsiveHelper responsive;

  const InfoRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: responsive.fontSize(20),
          color: Colors.grey.shade600,
        ),
        SizedBox(width: responsive.width(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

