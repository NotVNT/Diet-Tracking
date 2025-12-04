import 'package:flutter/material.dart';

import '../../../data/models/food_scanner_models.dart';
import 'animated_scanner_background.dart';
import 'scanner_constants.dart';
import 'scanner_styles.dart';
import 'scanner_layout.dart';

// ============================================================================
// SCANNER CONTROLS
// ============================================================================

/// Main control widget for scanner actions (food, barcode, gallery)
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
                if (selectedAction == ScannerActionType.food || selectedAction == ScannerActionType.gallery) ...[
          const SizedBox(height: ScannerDims.xl),
          _ScannerCaptureButton(action: selectedAction, onPressed: onCapture),
        ],
      ],
    );
  }
}

/// Individual action button widget
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
      duration: ScannerDurations.actionSwitch,
      decoration: ScannerDecorations.actionButton(
        selected: selected,
        radius: ScannerDims.actionButtonRadius,
        borderWidth: ScannerDims.actionBorderWidth,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ScannerDims.actionButtonRadius),
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
                style: ScannerTextStyles.actionLabel(selected: selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular capture button for photo/gallery
class _ScannerCaptureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ScannerActionType action;

  const _ScannerCaptureButton({required this.onPressed, required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: ScannerDims.captureOuter,
        height: ScannerDims.captureOuter,
        decoration: ScannerDecorations.captureOuter(),
        child: Center(
          child: Container(
            width: ScannerDims.captureInner,
            height: ScannerDims.captureInner,
            decoration: ScannerDecorations.captureInner(
              isGallery: action == ScannerActionType.gallery,
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

// ============================================================================
// SCANNER TOOLBAR
// ============================================================================

/// Top toolbar with title, subtitle, and action buttons
class ScannerToolbar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onHelp;
  final VoidCallback onClose;

  const ScannerToolbar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onHelp,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ScannerToolbarIconButton(
                icon: Icons.help_outline,
                onPressed: onHelp,
              ),
              const Spacer(),
              _ScannerToolbarIconButton(
                icon: Icons.close,
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: ScannerTextStyles.title(),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: ScannerTextStyles.subtitle(),
          ),
        ],
      ),
    );
  }
}

/// Icon button for toolbar
class _ScannerToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ScannerToolbarIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 24,
      child: Container(
        width: ScannerDims.toolbarButtonSize,
        height: ScannerDims.toolbarButtonSize,
        decoration: ScannerDecorations.toolbarButton(ScannerDims.toolbarButtonRadius),
        child: Icon(icon, color: Colors.white, size: ScannerDims.toolbarIconSize),
      ),
    );
  }
}

// ============================================================================
// BARCODE MODE VIEW
// ============================================================================

/// View rendered while scanning barcode with a smaller frame.
class BarcodeModeView extends StatelessWidget {
  final TextStyle hintStyle;
  final Widget? cameraPreview;
  final bool isScanning;

  const BarcodeModeView({
    super.key,
    required this.hintStyle,
    this.cameraPreview,
    this.isScanning = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        final frameSize = BarcodeFrameCalculator.calculate(
          viewportWidth: maxWidth,
          viewportHeight: maxHeight,
        );
        final frameWidth = frameSize.width;
        final frameHeight = frameSize.height;

        return Stack(
          children: [
            if (cameraPreview != null)
              Positioned.fill(
                child: cameraPreview!,
              ),
            Center(
              child: Container(
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isScanning ? Colors.green : Colors.white,
                    width: 3,
                  ),
                ),
              ),
            ),

          ],
        );
      },
    );
  }
}

// ============================================================================
// FOOD SCAN MODE VIEW
// ============================================================================

/// View rendered while user scans food by taking a photo.
class ScanFoodModeView extends StatelessWidget {
  final Widget? cameraPreview;

  const ScanFoodModeView({
    super.key,
    this.cameraPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: cameraPreview ?? const AnimatedScannerBackground(),
        ),
      ],
    );
  }
}
