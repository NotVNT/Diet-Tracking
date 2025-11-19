import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/scanner_action_config.dart';

class ScannerControls extends StatelessWidget {
  final List<ScannerActionConfig> actions;
  final ScannerActionType selectedAction;
  final ValueChanged<ScannerActionType> onActionSelected;
  final VoidCallback onCapture;

  const ScannerControls({
    super.key,
    required this.actions,
    required this.selectedAction,
    required this.onActionSelected,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: actions
              .map(
                (action) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _ScannerActionButton(
                      config: action,
                      selected: action.type == selectedAction,
                      onPressed: () => onActionSelected(action.type),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        if (selectedAction != ScannerActionType.barcode) ...[
          const SizedBox(height: 20),
          _ScannerCaptureButton(action: selectedAction, onPressed: onCapture),
        ],
      ],
    );
  }
}

class _ScannerActionButton extends StatelessWidget {
  final ScannerActionConfig config;
  final bool selected;
  final VoidCallback onPressed;

  const _ScannerActionButton({
    required this.config,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.white : Colors.white24,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                config.icon,
                color: selected ? Colors.black : Colors.white,
                size: 22,
              ),
              const SizedBox(height: 8),
              Text(
                config.label,
                style: GoogleFonts.inter(
                  color: selected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerCaptureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ScannerActionType action;

  const _ScannerCaptureButton({required this.onPressed, required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 3),
        ),
        child: Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: action == ScannerActionType.gallery
                  ? Colors.white10
                  : Colors.white,
              border: action == ScannerActionType.gallery
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: action == ScannerActionType.gallery
                ? const Icon(Icons.photo_library_outlined, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}
