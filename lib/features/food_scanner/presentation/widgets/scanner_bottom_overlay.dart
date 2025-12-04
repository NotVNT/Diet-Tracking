import 'package:flutter/material.dart';

import '../../data/models/food_scanner_models.dart';
import 'scanner_widgets.dart';

/// Bottom overlay with gradient background and scanner controls.
/// Extracted to enable reuse and keep page widget lean.
class ScannerBottomOverlay extends StatelessWidget {
  final List<ScannerActionConfig> actions;
  final ScannerActionType selectedAction;
  final ValueChanged<ScannerActionType> onActionSelected;
  final VoidCallback onCapture;

  const ScannerBottomOverlay({
    super.key,
    required this.actions,
    required this.selectedAction,
    required this.onActionSelected,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
      child: ScannerControls(
        actions: actions,
        selectedAction: selectedAction,
        onActionSelected: onActionSelected,
        onCapture: onCapture,
      ),
    );
  }
}

