import 'dart:async';

import 'package:camera/camera.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/scanner_action_config.dart';
import '../../domain/entities/scanned_food_entity.dart';
import '../../domain/repositories/scanned_food_repository.dart';
import '../../data/datasources/scanned_food_local_datasource.dart';
import '../../data/repositories/scanned_food_repository_impl.dart';
import '../../services/barcode_scanner_service.dart';
import '../widgets/barcode_result_dialog.dart';
import '../widgets/scanner_controls.dart';
import '../widgets/scanner_preview.dart';
import '../widgets/scanner_toolbar.dart';

/// Screen allowing the user to scan food, barcodes, or pick images.
class FoodScannerPage extends StatefulWidget {
  const FoodScannerPage({super.key});

  @override
  State<FoodScannerPage> createState() => _FoodScannerPageState();
}

class _FoodScannerPageState extends State<FoodScannerPage> {
  ScannerActionType _selectedAction = ScannerActionType.food;
  final ImagePicker _picker = ImagePicker();
  late final ScannedFoodRepository _scannedFoodRepository;
  late final BarcodeScannerService _barcodeScannerService;

  bool _isUploading = false;
  CameraController? _cameraController;
  bool _isCameraInitializing = false;
  String? _cameraErrorMessage;
  
  // Real-time barcode scanning
  bool _isRealTimeScanning = false;
  String? _lastDetectedBarcode;
  DateTime? _lastBarcodeDetectionTime;

  bool _usesCameraAction(ScannerActionType type) =>
      type == ScannerActionType.food || type == ScannerActionType.barcode;

  @override
  void initState() {
    super.initState();
    _scannedFoodRepository = ScannedFoodRepositoryImpl(
      localDataSource: ScannedFoodLocalDataSource(),
    );
    _barcodeScannerService = BarcodeScannerService();
    _initializeCamera();
  }

  @override
  void dispose() {
    _stopRealTimeScanning();
    _cameraController?.dispose();
    _barcodeScannerService.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Camera init / permissions
  // ---------------------------------------------------------------------------

  Future<void> _initializeCamera() async {
    if (_isCameraInitializing) return;

    final hasPermission = await _ensureCameraPermission();
    if (!hasPermission) return;

    final previousController = _cameraController;
    setState(() {
      _isCameraInitializing = true;
      _cameraErrorMessage = null;
      _cameraController = null;
    });

    if (previousController != null) {
      await previousController.dispose();
    }

    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() {
          _cameraErrorMessage = 'Không tìm thấy camera trên thiết bị.';
        });
        return;
      }

      // Ưu tiên camera sau, nếu không có thì dùng camera đầu tiên.
      final CameraDescription backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // veryHigh thường map 1920x1080 (16:9) trên Android → gần với camera gốc.
      final controller = CameraController(
        backCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
      });

      // Bắt đầu real-time scanning nếu đang ở chế độ barcode
      if (_selectedAction == ScannerActionType.barcode) {
        _startRealTimeScanning();
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _cameraErrorMessage = e.description ?? e.code;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraErrorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<bool> _ensureCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isDenied || status.isRestricted) {
      status = await Permission.camera.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
    }

    if (mounted) {
      final bool permanentlyDenied = status.isPermanentlyDenied;
      final message = permanentlyDenied
          ? 'Hãy bật quyền camera trong Cài đặt để tiếp tục quét.'
          : 'Ứng dụng cần quyền camera để quét.';
      setState(() {
        _cameraErrorMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: permanentlyDenied
              ? SnackBarAction(
                  label: 'Cài đặt',
                  onPressed: () {
                    openAppSettings();
                  },
                )
              : null,
        ),
      );
    }

    return false;
  }

  // ---------------------------------------------------------------------------
  // UI callbacks
  // ---------------------------------------------------------------------------

  void _onActionSelected(ScannerActionType type) {
    if (type == ScannerActionType.gallery) {
      _openGalleryPicker();
      return;
    }

    if (_selectedAction == type) {
      _ensureCameraForAction(type);
      return;
    }

    // Stop real-time scanning if switching away from barcode mode
    if (_selectedAction == ScannerActionType.barcode && type != ScannerActionType.barcode) {
      _stopRealTimeScanning();
    }

    _ensureCameraForAction(type);

    setState(() {
      _selectedAction = type;
    });

    // Start real-time scanning if switching to barcode mode
    if (type == ScannerActionType.barcode) {
      _startRealTimeScanning();
    }
  }

  void _onCapturePressed() {
    final l10n = AppLocalizations.of(context)!;
    switch (_selectedAction) {
      case ScannerActionType.food:
        _capturePhoto(ScanType.food, l10n.foodScannerPlaceholderCaptureFood);
        break;
      case ScannerActionType.barcode:
        _capturePhoto(ScanType.barcode, l10n.foodScannerPlaceholderScanBarcode);
        break;
      case ScannerActionType.gallery:
        _openGalleryPicker();
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Capture & save
  // ---------------------------------------------------------------------------

  Future<void> _capturePhoto(
    ScanType scanType,
    String placeholderMessage,
  ) async {
    if (_isUploading) return;

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      if (!_isCameraInitializing) {
        _initializeCamera();
      }
      if (mounted) {
        _showPlaceholderMessage(placeholderMessage);
      }
      return;
    }

    try {
      final XFile photo = await controller.takePicture();
      if (mounted) {
        await _saveScannedFood(photo.path, scanType);
      }
    } on CameraException catch (_) {
      if (mounted) {
        _showPlaceholderMessage(placeholderMessage);
      }
    } catch (_) {
      if (mounted) {
        _showPlaceholderMessage(placeholderMessage);
      }
    }
  }

  Future<void> _saveScannedFood(String imagePath, ScanType scanType) async {
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
    });

    try {
      final scannedFood = ScannedFoodEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        scanType: scanType,
        scanDate: DateTime.now(),
      );

      await _scannedFoodRepository.saveScannedFood(scannedFood);
      if (mounted) {
        _showSuccessMessage();
      }
    } catch (_) {
      if (mounted) {
        _showErrorMessage();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.foodScannerPlaceholderCaptureFood ??
              'Đã lưu ảnh thành công',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage() {
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizations?.networkError ??
              'Không thể tải ảnh lên Cloudinary. Vui lòng thử lại.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
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

  void _showPlaceholderMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ---------------------------------------------------------------------------
  // Gallery
  // ---------------------------------------------------------------------------

  void _openGalleryPicker() {
    if (_isUploading) return;
    _pickFromGallery();
  }

  Future<void> _pickFromGallery() async {
    final errorMessage =
        AppLocalizations.of(context)?.foodScannerPlaceholderOpenGallery ??
            'Không thể mở thư viện. Vui lòng thử lại.';
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // Thử quét barcode từ ảnh
        await _scanBarcodeFromImage(image.path);
      }
    } catch (_) {
      if (mounted) {
        _showPlaceholderMessage(errorMessage);
      }
    }
  }

  /// Quét barcode từ ảnh được chọn
  Future<void> _scanBarcodeFromImage(String imagePath) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Quét barcode
      final barcodes = await _barcodeScannerService.scanBarcodeFromImage(imagePath);

      if (!mounted) return;

      if (barcodes.isEmpty) {
        // Không tìm thấy barcode, lưu như ảnh thông thường
        await _saveScannedFood(imagePath, ScanType.gallery);
        _showPlaceholderMessage('Không tìm thấy mã vạch trong ảnh');
      } else {
        // Tìm thấy barcode, hiển thị dialog
        await _showBarcodeResultDialog(barcodes, imagePath);
      }
    } catch (e) {
      if (mounted) {
        // Nếu có lỗi khi quét barcode, vẫn lưu ảnh
        await _saveScannedFood(imagePath, ScanType.gallery);
        _showPlaceholderMessage('Đã lưu ảnh');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Hiển thị dialog kết quả barcode
  Future<void> _showBarcodeResultDialog(
    List<Barcode> barcodes,
    String imagePath,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BarcodeResultDialog(
        barcodes: barcodes,
        imagePath: imagePath,
        onClose: () => Navigator.of(context).pop(),
        onBarcodeSelected: (barcode) => _handleBarcodeSelected(barcode, imagePath),
      ),
    );
  }

  /// Xử lý khi người dùng chọn một barcode
  void _handleBarcodeSelected(Barcode barcode, String imagePath) {
    final barcodeValue = barcode.displayValue ?? barcode.rawValue ?? '';
    
    // Lưu ảnh với barcode
    _saveScannedFood(imagePath, ScanType.barcode);
    
    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu mã: $barcodeValue'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Real-time barcode scanning
  // ---------------------------------------------------------------------------

  /// Bắt đầu quét barcode real-time
  void _startRealTimeScanning() {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() {
      _isRealTimeScanning = true;
      _lastDetectedBarcode = null;
    });

    controller.startImageStream((CameraImage image) {
      _processCameraImage(image);
    });
  }

  /// Dừng quét barcode real-time
  void _stopRealTimeScanning() {
    final controller = _cameraController;
    if (controller != null && controller.value.isStreamingImages) {
      controller.stopImageStream();
    }

    setState(() {
      _isRealTimeScanning = false;
      _lastDetectedBarcode = null;
    });
  }

  /// Xử lý camera image để tìm barcode
  Future<void> _processCameraImage(CameraImage image) async {
    if (!_isRealTimeScanning || _isUploading) return;

    try {
      final barcode = await _barcodeScannerService.scanBarcodeFromCameraImage(image);
      
      if (barcode != null && mounted) {
        final barcodeValue = barcode.displayValue ?? barcode.rawValue ?? '';
        
        // Tránh detect cùng một mã nhiều lần
        if (barcodeValue == _lastDetectedBarcode) {
          final now = DateTime.now();
          if (_lastBarcodeDetectionTime != null &&
              now.difference(_lastBarcodeDetectionTime!).inSeconds < 3) {
            return;
          }
        }

        // Tìm thấy barcode mới
        _lastDetectedBarcode = barcodeValue;
        _lastBarcodeDetectionTime = DateTime.now();
        
        // Dừng scanning và lưu
        await _onBarcodeDetected(barcode);
      }
    } catch (e) {
      // Ignore errors during real-time scanning
    }
  }

  /// Xử lý khi phát hiện barcode
  Future<void> _onBarcodeDetected(Barcode barcode) async {
    _stopRealTimeScanning();

    if (!mounted) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Chụp ảnh hiện tại
      final controller = _cameraController;
      if (controller != null && controller.value.isInitialized) {
        final XFile photo = await controller.takePicture();
        
        // Lưu với barcode
        await _saveScannedFood(photo.path, ScanType.barcode);
        
        final barcodeValue = barcode.displayValue ?? barcode.rawValue ?? '';
        
        if (mounted) {
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã quét mã: $barcodeValue'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Đóng scanner và quay về homepage
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage();
        _startRealTimeScanning(); // Tiếp tục scan nếu có lỗi
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Camera preview
  // ---------------------------------------------------------------------------

  Widget? _buildCameraPreview() {
    if (_cameraErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _cameraErrorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    if (_isCameraInitializing) {
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

  void _ensureCameraForAction(ScannerActionType type) {
    if (!_usesCameraAction(type)) return;
    final controller = _cameraController;
    final needsInitialization =
        controller == null || !controller.value.isInitialized;
    if (needsInitialization && !_isCameraInitializing) {
      unawaited(_initializeCamera());
    }
  }

  Widget _buildScannerControls(List<ScannerActionConfig> actions) {
    final bool disableCapture = _isUploading || _isCameraInitializing || _selectedAction == ScannerActionType.barcode;
    return ScannerControls(
      actions: actions,
      selectedAction: _selectedAction,
      onActionSelected: _onActionSelected,
      onCapture: disableCapture ? () {} : _onCapturePressed,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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
              action: _selectedAction,
              overlayText: l10n.foodScannerOverlayAutoDetect,
              barcodeHint: l10n.foodScannerOverlayBarcodeHint,
              overlayTextStyle: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
              ),
              cameraPreview: _buildCameraPreview(),
              barcodeControlsOverlay: null,
              isRealTimeScanning: _isRealTimeScanning,
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
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                  child: _buildScannerControls(actions),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
