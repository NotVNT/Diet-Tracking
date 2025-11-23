import 'package:camera/camera.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/food_scanner_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/scanned_food_entity.dart';
import '../../data/repositories/scanned_food_repository_impl.dart';
import '../../domain/usecases/get_barcode_product_info.dart';
import '../../domain/usecases/request_camera_permission.dart';
import '../../domain/usecases/save_scanned_food.dart';
import '../../domain/usecases/scan_barcode_from_image.dart';
import '../../services/barcode_api_service.dart';
import '../../services/session_permission_service.dart';
import '../bloc/food_scanner_bloc.dart';
import '../bloc/food_scanner_event.dart';
import '../../../chat_bot_view_home/data/repositories/user_repository_impl.dart';
import '../../../chat_bot_view_home/data/datasources/firestore_datasource.dart';
import '../../../../database/auth_service.dart';

import '../../services/barcode_scanner_service.dart' as barcode_service;
import '../widgets/food_scanner_page_widget/scanner_widgets.dart';
import '../widgets/food_scanner_page_widget/scanner_preview.dart';
import '../bloc/food_scanner_state.dart';
import '../../services/food_recognition_service.dart';
import '../../../../utils/snackbar_helper.dart';

/// Screen allowing the user to scan food, barcodes, or pick images.
class FoodScannerPage extends StatefulWidget {
  const FoodScannerPage({super.key});

  @override
  State<FoodScannerPage> createState() => _FoodScannerPageState();
}

class _FoodScannerPageState extends State<FoodScannerPage> {
  late final FoodScannerBloc _bloc;
  // UI mirror states (sync via BlocListener)
  late ActionSelectedState _actionState;
  late UploadingState _uploadingState;
  late CameraInitializingState _cameraInitState;
  late CameraErrorState? _cameraErrorState;
  late RealTimeScanningState _realTimeScanState;
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    // Local UI mirrors of bloc state
    _actionState = const ActionSelectedState(
      selectedAction: ScannerActionType.food,
    );
    _uploadingState = const UploadingState(isUploading: false);
    _cameraInitState = const CameraInitializingState(isInitializing: false);
    _cameraErrorState = null;
    _realTimeScanState = const RealTimeScanningState(isScanning: false);

    // Build dependencies and create bloc
    final repository = ScannedFoodRepositoryImpl();
    final scannerService = barcode_service.BarcodeScannerService();
    final apiService = BarcodeApiService();
    final foodRecognition = FoodRecognitionService();

    final scanBarcodeFromImage = ScanBarcodeFromImage(scannerService);
    final requestPermission = RequestCameraPermission(
      SessionPermissionService(),
    );
    final saveScannedFood = SaveScannedFood(repository);
    final userRepo = UserRepositoryImpl(FirestoreDatasource(), AuthService());
    final getProductInfo = GetBarcodeProductInfo(apiService, userRepo);

    _bloc = FoodScannerBloc(
      scannedFoodRepository: repository,
      barcodeScannerService: scannerService,
      barcodeApiService: apiService,
      scanBarcodeFromImageUseCase: scanBarcodeFromImage,
      requestCameraPermissionUseCase: requestPermission,
      saveScannedFoodUseCase: saveScannedFood,
      getBarcodeProductInfoUseCase: getProductInfo,
      foodRecognitionService: foodRecognition,
    );

    _bloc.add(const InitializeCameraEvent());
  }

  @override
  void dispose() {
    _bloc.close();
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

  void _syncState(FoodScannerState state) {
    if (state is ActionSelectedState) {
      _actionState = state;
    } else if (state is UploadingState) {
      _uploadingState = state;
    } else if (state is CameraInitializingState) {
      _cameraInitState = state;
    } else if (state is CameraErrorState) {
      _cameraErrorState = state;
    } else if (state is CameraReadyState) {
      _cameraController = state.controller;
      _cameraErrorState = null;
    } else if (state is RealTimeScanningState) {
      _realTimeScanState = state;
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
    _bloc.add(ActionSelectedEvent(actionType: type));
    // Nếu chọn Gallery, mở thư viện ngay
    if (type == ScannerActionType.gallery) {
      _bloc.add(
        CapturePhotoEvent(
          scanType: ScanType.gallery,
          placeholderMessage: 'Không thể mở thư viện, vui lòng thử lại.',
        ),
      );
    }
  }

  void _onCapturePressed() {
    final selected = _actionState.selectedAction;
    final scanType = selected == ScannerActionType.food
        ? ScanType.food
        : ScanType.gallery;
    _bloc.add(
      CapturePhotoEvent(
        scanType: scanType,
        placeholderMessage: 'Không thể chụp ảnh, vui lòng thử lại.',
      ),
    );
  }

  Widget _buildScannerControls(List<ScannerActionConfig> actions) {
    final action = _actionState.selectedAction;

    // Chỉ disable capture khi:
    // - Đang upload
    // - Ở chế độ Barcode (nút capture ẩn theo UI)
    // - Ở chế độ Food và camera đang initializing
    final bool disableCapture =
        _uploadingState.isUploading ||
        action == ScannerActionType.barcode ||
        (action == ScannerActionType.food && _cameraInitState.isInitializing);

    return ScannerControls(
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

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<FoodScannerBloc, FoodScannerState>(
        listener: (context, state) {
          setState(() => _syncState(state));

          // Show notifications and navigate on success/error
          if (state is ScanSuccessState) {
            SnackBarHelper.showSuccess(context, state.message);
            // Pop back to previous (home) after a short delay
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!mounted) return;
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          } else if (state is ScanErrorState) {
            SnackBarHelper.showError(context, state.message);
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!mounted) return;
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          } else if (state is NoBarcodeFoundState) {
            // Chỉ thông báo; KHÔNG pop ở đây để đợi lưu xong (ScanSuccessState)
            SnackBarHelper.showInfo(
              context,
              'Đang lưu ảnh...',
            );
          } else if (state is CameraErrorState) {
            SnackBarHelper.showError(context, state.errorMessage);
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!mounted) return;
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          }
        },
        child: Scaffold(
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
        ),
      ),
    );
  }
}
