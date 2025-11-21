import 'dart:async';
import 'package:camera/camera.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/food_scanner_models.dart';
import '../../services/barcode_scanner_service.dart' as barcode_service;
import '../widgets/food_scanner_page_widget/scanner_widgets.dart';
import '../widgets/food_scanner_page_widget/scanner_preview.dart';
import '../bloc/food_scanner_state.dart';

/// Screen allowing the user to scan food, barcodes, or pick images.
class FoodScannerPage extends StatefulWidget {
  const FoodScannerPage({super.key});

  @override
  State<FoodScannerPage> createState() => _FoodScannerPageState();
}

class _FoodScannerPageState extends State<FoodScannerPage> {
  // State management
  late ActionSelectedState _actionState;
  late UploadingState _uploadingState;
  late CameraInitializingState _cameraInitState;
  late CameraErrorState? _cameraErrorState;
  late RealTimeScanningState _realTimeScanState;

  // Dependencies
  late final barcode_service.BarcodeScannerService _barcodeScannerService;

  // Camera
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    // Initialize states
    _actionState = ActionSelectedState(selectedAction: ScannerActionType.food);
    _uploadingState = UploadingState(isUploading: false);
    _cameraInitState = CameraInitializingState(isInitializing: false);
    _cameraErrorState = null;
    _realTimeScanState = RealTimeScanningState(isScanning: false);

    // Initialize dependencies
    _barcodeScannerService = barcode_service.BarcodeScannerService();
    _initializeCamera();
  }

  @override
  void dispose() {
    _stopRealTimeScanning();
    _cameraController?.dispose();
    _barcodeScannerService.dispose();
    super.dispose();
  }

  List<ScannerActionConfig> _buildActions(AppLocalizations l10n) {
    return [
      ScannerActionConfig(
        type: ScannerActionType.food,
        label: l10n.foodScannerActionFood,
        icon: Icons.restaurant_outlined,
      ),
      ScannerActionConfig(
        type: ScannerActionType.barcode,
        label: l10n.foodScannerActionBarcode,
        icon: Icons.qr_code_scanner,
      ),
      ScannerActionConfig(
        type: ScannerActionType.gallery,
        label: l10n.foodScannerActionGallery,
        icon: Icons.photo_library_outlined,
      ),
    ];
  }



  void _showHelp() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.foodScannerHelpTitle,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              l10n.foodScannerHelpTip1,
              l10n.foodScannerHelpTip2,
              l10n.foodScannerHelpTip3,
            ].map(
              (tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget? _buildCameraPreview() {
    if (_cameraErrorState != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _cameraErrorState!.errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    if (_cameraInitState.isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return null;
    }

    // Camera sensor thường trả về landscape (ngang), nhưng app dùng portrait (dọc).
    // Đảo ngược tỷ lệ để preview dọc khớp với ảnh chụp.
    final previewAspectRatio = controller.value.aspectRatio;
    if (previewAspectRatio <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        if (maxWidth <= 0 || maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        // Đảo tỷ lệ từ landscape (ngang) sang portrait (dọc).
        final correctedAspectRatio = 1 / previewAspectRatio;

        return Center(
          child: AspectRatio(
            aspectRatio: correctedAspectRatio,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }



  void _onActionSelected(ScannerActionType type) {
    setState(() {
      _actionState = ActionSelectedState(selectedAction: type);
    });
  }

  void _onCapturePressed() {
    // Placeholder for capture action
  }

  Future<void> _initializeCamera() async {
    // Placeholder for camera initialization
  }

  void _stopRealTimeScanning() {
    setState(() {
      _realTimeScanState = RealTimeScanningState(isScanning: false);
    });
  }

  Widget _buildScannerControls(List<ScannerActionConfig> actions) {
    final bool disableCapture = _uploadingState.isUploading ||
        _cameraInitState.isInitializing ||
        _actionState.selectedAction == ScannerActionType.barcode;
    return ScannerControls(
      actions: actions,
      selectedAction: _actionState.selectedAction,
      onActionSelected: _onActionSelected,
      onCapture: disableCapture ? () {} : _onCapturePressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = _buildActions(l10n);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: ScannerPreview(
              action: _actionState.selectedAction,
              overlayText: l10n.foodScannerOverlayAutoDetect,
              barcodeHint: l10n.foodScannerOverlayBarcodeHint,
              overlayTextStyle: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
              ),
              cameraPreview: _buildCameraPreview(),
              barcodeControlsOverlay: null,
              isRealTimeScanning: _realTimeScanState.isScanning,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                ScannerToolbar(
                  title: l10n.foodScannerTitle,
                  subtitle: l10n.foodScannerSubtitle,
                  onHelp: _showHelp,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                Container(
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
                  child: _buildScannerControls(actions),
                ),
              ],
            ),
          ),
          if (_uploadingState.isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
