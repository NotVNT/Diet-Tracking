import 'package:camera/camera.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/food_scanner_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/food_scanner_injector.dart';
import '../bloc/food_scan/food_scan_bloc.dart';
import '../bloc/food_scan/food_scan_event.dart';
import '../bloc/food_scan/food_scan_state.dart';
import '../bloc/barcode/barcode_bloc.dart';
import '../bloc/barcode/barcode_event.dart';
import '../bloc/barcode/barcode_state.dart';
import '../widgets/food_scanner_page_widget/scanner_widgets.dart';
import '../widgets/food_scanner_page_widget/scanner_preview.dart';
import '../widgets/food_scanner_page_widget/scanner_bottom_overlay.dart';
import '../widgets/food_scanner_page_widget/camera_preview_wrapper.dart';
import '../../di/food_scanner_locator.dart';

import '../../../../utils/snackbar_helper.dart';
import '../bloc/camera/camera_bloc.dart' as cam;
import '../bloc/camera/camera_event.dart' as cam_event;
import '../bloc/camera/camera_state.dart' as cam_state;
import '../../services/barcode_scanner_service.dart' as barcode_service;


/// Screen allowing the user to scan food, barcodes, or pick images.
class FoodScannerPage extends StatefulWidget {
  final FoodScannerInjector? injector;
  const FoodScannerPage({super.key, this.injector});

  @override
  State<FoodScannerPage> createState() => _FoodScannerPageState();
}

class _FoodScannerPageState extends State<FoodScannerPage> {
  late final FoodScanBloc _foodScanBloc;
  late final BarcodeBloc _barcodeBloc;
  late final cam.CameraBloc _cameraBloc;
  // Ownership flag for DI resources created via Injector (not Locator)
  bool _ownsDependencies = false;
  // UI mirror states (sync via BlocListener)
  late ScannerActionType _selectedAction;
  bool _isUploading = false;
  bool _cameraInitializing = false;
  String? _cameraError;
  bool _isStreaming = false;
  CameraController? _cameraController;
  String? _pendingImagePath;
  bool _isBarcodeCapturing = false;
  late final barcode_service.BarcodeScannerService _barcodeScannerService;

  @override
  void initState() {
    super.initState();
    // Local UI mirrors of bloc state
    _selectedAction = ScannerActionType.food;
    _isUploading = false;
    _cameraInitializing = false;
    _cameraError = null;
    _isStreaming = false;

    // Build dependencies and create blocs
    _initDependenciesAndBlocs();
  }

  @override
  void dispose() {
    if (_ownsDependencies) {
      _cameraBloc.close();
      _foodScanBloc.close();
      _barcodeBloc.close();
      _barcodeScannerService.dispose();
    }
    super.dispose();
  }
  void _initDependenciesAndBlocs() {
    // Prefer feature locator if already set up, otherwise use injector
    if (FoodScannerLocator.isInitialized) {
      _foodScanBloc = FoodScannerLocator.I<FoodScanBloc>();
      _barcodeBloc = FoodScannerLocator.I<BarcodeBloc>();
      _cameraBloc = FoodScannerLocator.I<cam.CameraBloc>();
      _barcodeScannerService = FoodScannerLocator.I<barcode_service.BarcodeScannerService>();
      _ownsDependencies = false;
      return;
    }

    final injector = widget.injector ?? FoodScannerInjector();
    final deps = injector.create();
    _foodScanBloc = deps.foodScanBloc;
    _barcodeBloc = deps.barcodeBloc;
    _cameraBloc = deps.cameraBloc;
    _barcodeScannerService = deps.barcodeScannerService;
    _ownsDependencies = true;
  }

  void _handleFoodScanState(BuildContext context, FoodScanState state) {
    setState(() => _syncState(state));

    // Show notifications and navigate on success/error
    if (state is FoodScanSuccess) {
      SnackBarHelper.showSuccess(context, state.message);
      _popAfterShortDelay();
    } else if (state is FoodScanError) {
      SnackBarHelper.showError(context, state.message);
      _popAfterShortDelay();
    }
  }

  void _handleBarcodeState(BuildContext context, BarcodeState state) async {
    if (state is BarcodeUploading) {
      setState(() => _isUploading = true);
    } else if (state is BarcodeSavedSuccess) {
      setState(() => _isUploading = false);
      SnackBarHelper.showSuccess(context, state.message);
      _popAfterShortDelay();
    } else if (state is BarcodeNoBarcodeFound) {
      setState(() => _isUploading = false);
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showInfo(context, l10n.foodScannerNoBarcodeFoundSaving);
      _foodScanBloc.add(FoodScanRequested(imagePath: state.imagePath));
    } else if (state is BarcodeError) {
      setState(() => _isUploading = false);
      SnackBarHelper.showError(context, state.message);
      final path = _pendingImagePath;
      if (path != null) {
        _foodScanBloc.add(FoodScanRequested(imagePath: path));
        _pendingImagePath = null;
      }
    } else if (state is BarcodeValueDetected) {
      if (_isBarcodeCapturing) return;
      _isBarcodeCapturing = true;
      try {
        final controller = _cameraController;
        if (controller == null || !controller.value.isInitialized) {
          _isBarcodeCapturing = false;
          return;
        }
        final photo = await controller.takePicture();
        _pendingImagePath = photo.path;
        _barcodeBloc.add(BarcodeSelected(state.barcodeValue, imagePath: photo.path));
      } catch (_) {
        _isBarcodeCapturing = false;
      }
    }
  }

  void _handleCameraState(BuildContext context, cam_state.CameraState state) async {
    if (state is cam_state.CameraInitializing) {
      setState(() => _cameraInitializing = state.isInitializing);
    } else if (state is cam_state.CameraError) {
      setState(() => _cameraError = state.errorMessage);
      SnackBarHelper.showError(context, state.errorMessage);
      final navigator = Navigator.of(context);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      if (navigator.canPop()) {
        navigator.pop();
      }
    } else if (state is cam_state.CameraReady) {
      setState(() {
        _cameraError = null;
        _cameraController = state.controller;
      });
    } else if (state is cam_state.CameraStreamingState) {
      setState(() => _isStreaming = state.isStreaming);
    } else if (state is cam_state.CameraFrameAvailable) {
      if (_selectedAction == ScannerActionType.barcode && !_isUploading) {
        _barcodeBloc.add(BarcodeScanFromCameraFrameRequested(state.image));
      }
    }
  }


  void _popAfterShortDelay() {
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (navigator.canPop()) {
        navigator.pop();
      }
    });
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

  void _syncState(FoodScanState state) {
    if (state is FoodScanUploading) {
      _isUploading = true;
    } else if (state is FoodScanSuccess || state is FoodScanError) {
      _isUploading = false;
    }
  }

  void _syncActionState(ScannerActionType action) {
    _selectedAction = action;
    // Start/stop camera streaming based on selected action
    if (action == ScannerActionType.barcode) {
      _cameraBloc.add(const cam_event.StartImageStream());
    } else {
      _cameraBloc.add(const cam_event.StopImageStream());
    }
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


  void _onActionSelected(ScannerActionType type) {
    setState(() => _syncActionState(type));
    // If user selects Gallery, open picker immediately
    if (type == ScannerActionType.gallery) {
      _openGallery();
    }
  }

  Future<void> _openGallery() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // If gallery chosen, attempt barcode scan from image, fallback handled by bloc listener
    _pendingImagePath = picked.path;
    _barcodeBloc.add(BarcodeScanFromImageRequested(picked.path));
  }

  Future<void> _onCapturePressed() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      SnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.foodScannerCantCapturePhoto,
      );
      return;
    }

    try {
      final photo = await controller.takePicture();
      // Trigger food scan for captured image
      _foodScanBloc.add(FoodScanRequested(imagePath: photo.path));
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.foodScannerCantCapturePhoto,
      );
    }
  }


  Widget _buildScannerControls(List<ScannerActionConfig> actions) {
    final action = _selectedAction;

    // Disable capture when:
    // - Uploading
    // - In Barcode mode (capture button hidden by UI)
    // - In Food mode while camera is initializing
    final bool disableCapture =
        _isUploading ||
        action == ScannerActionType.barcode ||
        (action == ScannerActionType.food && _cameraInitializing);

    return ScannerBottomOverlay(
      actions: actions,
      selectedAction: action,
      onActionSelected: _onActionSelected,
      onCapture: disableCapture ? () {} : _onCapturePressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = _buildActions(l10n);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _foodScanBloc),
        BlocProvider<BarcodeBloc>.value(value: _barcodeBloc),
        BlocProvider<cam.CameraBloc>.value(value: _cameraBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FoodScanBloc, FoodScanState>(
            listener: _handleFoodScanState,
          ),
          BlocListener<BarcodeBloc, BarcodeState>(
            listener: _handleBarcodeState,
          ),
          BlocListener<cam.CameraBloc, cam_state.CameraState>(
            listener: _handleCameraState,
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: ScannerPreview(
                  action: _selectedAction,
                  overlayText: l10n.foodScannerOverlayAutoDetect,
                  barcodeHint: l10n.foodScannerOverlayBarcodeHint,
                  overlayTextStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  cameraPreview: CameraPreviewWrapper(
                    controller: _cameraController,
                    isInitializing: _cameraInitializing,
                    errorMessage: _cameraError,
                  ),
                  barcodeControlsOverlay: null,
                  isRealTimeScanning: _isStreaming,
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
                    _buildScannerControls(actions),
                  ],
                ),
              ),
              if (_isUploading)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
