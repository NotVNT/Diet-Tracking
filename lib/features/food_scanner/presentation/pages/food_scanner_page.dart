import 'package:camera/camera.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/scanner_action_config.dart';
import '../../domain/entities/scanned_food_entity.dart';
import '../../domain/repositories/scanned_food_repository.dart';
import '../../data/datasources/scanned_food_local_datasource.dart';
import '../../data/repositories/scanned_food_repository_impl.dart';
import '../widgets/scanner_controls.dart';
import '../widgets/scanner_preview.dart';
import '../widgets/scanner_toolbar.dart';

/// Screen allowing the user to scan food, barcodes, or pick images.
///
/// The class is UI-focused so later camera/barcode integrations can plug into
/// `ScannerPreview` and the callbacks defined in [_FoodScannerPageState].
class FoodScannerPage extends StatefulWidget {
  const FoodScannerPage({super.key});

  @override
  State<FoodScannerPage> createState() => _FoodScannerPageState();
}

class _FoodScannerPageState extends State<FoodScannerPage> {
  ScannerActionType _selectedAction = ScannerActionType.food;
  final ImagePicker _picker = ImagePicker();
  late final ScannedFoodRepository _scannedFoodRepository;
  bool _isUploading = false;
  CameraController? _cameraController;
  bool _isCameraInitializing = false;
  String? _cameraErrorMessage;

  @override
  void initState() {
    super.initState();
    _scannedFoodRepository = ScannedFoodRepositoryImpl(
      localDataSource: ScannedFoodLocalDataSource(),
    );
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
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

  Future<void> _initializeCamera() async {
    if (_isCameraInitializing) return;

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

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
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

  void _onActionSelected(ScannerActionType type) {
    if (type == ScannerActionType.gallery) {
      _openGalleryPicker();
      return;
    }

    if (_selectedAction == type) {
      return;
    }

    setState(() {
      _selectedAction = type;
    });
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

  /// Capture photo using camera
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

  /// Save scanned food to repository
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
    } catch (e) {
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

  void _openGalleryPicker() {
    if (_isUploading) return;
    _pickFromGallery();
  }

  /// Pick image from gallery
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
        await _saveScannedFood(image.path, ScanType.gallery);
      }
    } catch (e) {
      if (mounted) {
        _showPlaceholderMessage(errorMessage);
      }
    }
  }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        if (maxWidth <= 0 || maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        final previewAspectRatio = controller.value.aspectRatio;
        if (previewAspectRatio <= 0) {
          return const SizedBox.shrink();
        }
        final viewAspectRatio = maxWidth / maxHeight;
        final scale = previewAspectRatio / viewAspectRatio;
        final fittedScale = scale < 1 ? (1 / scale) : scale;

        return ClipRect(
          child: Transform.scale(
            scale: fittedScale.isFinite ? fittedScale : 1,
            alignment: Alignment.center,
            child: Center(
              child: AspectRatio(
                aspectRatio: previewAspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
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
              action: _selectedAction,
              overlayText: l10n.foodScannerOverlayAutoDetect,
              barcodeHint: l10n.foodScannerOverlayBarcodeHint,
              overlayTextStyle: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
              ),
              cameraPreview: _buildCameraPreview(),
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
                  child: ScannerControls(
                    actions: actions,
                    selectedAction: _selectedAction,
                    onActionSelected: _onActionSelected,
                    onCapture: (_isUploading || _isCameraInitializing)
                        ? () {}
                        : _onCapturePressed,
                  ),
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
