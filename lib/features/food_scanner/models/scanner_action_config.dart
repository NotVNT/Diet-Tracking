import 'package:flutter/material.dart';

/// Supported scanner actions.
enum ScannerActionType { food, barcode, gallery }

/// Metadata describing each scanner action button.
class ScannerActionConfig {
  final ScannerActionType type;
  final String label;
  final IconData icon;

  const ScannerActionConfig({
    required this.type,
    required this.label,
    required this.icon,
  });
}
