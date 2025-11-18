import 'package:flutter/material.dart';
import '../../models/scanner_action_config.dart';
import '../modes/barcode_mode.dart';
import '../modes/gallery_mode.dart';
import '../modes/scan_food_mode.dart';

class ScannerPreview extends StatelessWidget {
  final ScannerActionType action;
  final String overlayText;
  final String barcodeHint;
  final String galleryTitle;
  final String gallerySubtitle;
  final String galleryButtonLabel;
  final TextStyle overlayTextStyle;
  final VoidCallback onGalleryPick;

  const ScannerPreview({
    super.key,
    required this.action,
    required this.overlayText,
    required this.barcodeHint,
    required this.galleryTitle,
    required this.gallerySubtitle,
    required this.galleryButtonLabel,
    required this.overlayTextStyle,
    required this.onGalleryPick,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: _buildModeView(),
    );
  }

  Widget _buildModeView() {
    switch (action) {
      case ScannerActionType.food:
        return ScanFoodModeView(
          overlayText: overlayText,
          overlayTextStyle: overlayTextStyle,
        );
      case ScannerActionType.barcode:
        return BarcodeModeView(
          bottomHint: barcodeHint,
          hintStyle: overlayTextStyle,
        );
      case ScannerActionType.gallery:
        return GalleryModeView(
          title: galleryTitle,
          subtitle: gallerySubtitle,
          buttonLabel: galleryButtonLabel,
          onPick: onGalleryPick,
        );
    }
  }
}
