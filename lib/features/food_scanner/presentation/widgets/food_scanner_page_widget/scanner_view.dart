import 'package:diet_tracking_project/features/food_scanner/data/models/food_scanner_models.dart';
import '../../controller/scanner_controller.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_state.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_bloc.dart' as cam;
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/camera/camera_state.dart' as cam_state;
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_state.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/food_scanner_page_widget/camera_preview_wrapper.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/food_scanner_page_widget/scanner_bottom_overlay.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/food_scanner_page_widget/scanner_preview.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/food_scanner_page_widget/scanner_widgets.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'scanner_help_sheet.dart';

class ScannerView extends StatefulWidget {
  final ScannerController controller;

  const ScannerView({super.key, required this.controller});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  ScannerActionType _selectedAction = ScannerActionType.food;

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

  void _onActionSelected(ScannerActionType type) {
    setState(() {
      _selectedAction = type;
    });
    widget.controller.onActionSelected(type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = _buildActions(l10n);

    return Scaffold(
      backgroundColor: Colors.black,
            body: BlocBuilder<cam.CameraBloc, cam_state.CameraState>(
        builder: (context, cameraState) {
          return BlocBuilder<FoodScanBloc, FoodScanState>(
            builder: (context, foodScanState) {
              return BlocBuilder<BarcodeBloc, BarcodeState>(
                builder: (context, barcodeState) {
                  final isUploading =
                      foodScanState is FoodScanUploading || barcodeState is BarcodeUploading;
                  final isCameraInitializing = cameraState is cam_state.CameraInitializing;

                  final bool disableCapture = isUploading ||
                      _selectedAction == ScannerActionType.barcode ||
                      (_selectedAction == ScannerActionType.food && isCameraInitializing);

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: ScannerPreview(
                          action: _selectedAction,
                          overlayTextStyle: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          cameraPreview: CameraPreviewWrapper(
                            // Use the CameraBloc controller regardless of specific state so
                            // preview stays visible during Barcode mode (streaming state).
                            controller: context.read<cam.CameraBloc>().controller,
                            isInitializing: isCameraInitializing,
                            errorMessage: cameraState is cam_state.CameraError
                                ? cameraState.errorMessage
                                : null,
                          ),
                          isRealTimeScanning: cameraState is cam_state.CameraStreamingState &&
                              cameraState.isStreaming,
                        ),
                      ),
                      SafeArea(
                        child: Column(
                          children: [
                            ScannerToolbar(
                              title: l10n.foodScannerTitle,
                              subtitle: l10n.foodScannerSubtitle,
                              onHelp: () => ScannerHelpSheet.show(context),
                              onClose: () => Navigator.of(context).pop(),
                            ),
                            const Spacer(),
                            ScannerBottomOverlay(
                              actions: actions,
                              selectedAction: _selectedAction,
                              onActionSelected: _onActionSelected,
                              onCapture: disableCapture ? () {} : widget.controller.onCapturePressed,
                            ),
                          ],
                        ),
                      ),
                      if (isUploading)
                        Container(
                          color: Colors.black.withAlpha((255 * 0.6).round()),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


