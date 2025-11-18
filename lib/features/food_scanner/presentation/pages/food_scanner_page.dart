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

  @override
  void initState() {
    super.initState();
    _scannedFoodRepository = ScannedFoodRepositoryImpl(
      localDataSource: ScannedFoodLocalDataSource(),
    );
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

  void _onActionSelected(ScannerActionType type) {
    setState(() {
      _selectedAction = type;
    });
    if (type == ScannerActionType.gallery) {
      _openGalleryPicker();
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

  /// Capture photo using camera
  Future<void> _capturePhoto(ScanType scanType, String placeholderMessage) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        await _saveScannedFood(photo.path, scanType);
        _showSuccessMessage();
      }
    } catch (e) {
      if (mounted) {
        _showPlaceholderMessage(placeholderMessage);
      }
    }
  }

  /// Save scanned food to repository
  Future<void> _saveScannedFood(String imagePath, ScanType scanType) async {
    final scannedFood = ScannedFoodEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      scanType: scanType,
      scanDate: DateTime.now(),
    );
    
    await _scannedFoodRepository.saveScannedFood(scannedFood);
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.foodScannerPlaceholderCaptureFood ?? 
            'Đã lưu ảnh thành công'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openGalleryPicker() {
    final l10n = AppLocalizations.of(context)!;
    _pickFromGallery(l10n.foodScannerPlaceholderOpenGallery);
  }

  /// Pick image from gallery
  Future<void> _pickFromGallery(String placeholderMessage) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        await _saveScannedFood(image.path, ScanType.gallery);
        _showSuccessMessage();
      }
    } catch (e) {
      if (mounted) {
        _showPlaceholderMessage(placeholderMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = _buildActions(l10n);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            ScannerToolbar(
              title: l10n.foodScannerTitle,
              subtitle: l10n.foodScannerSubtitle,
              onHelp: _showHelp,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: ScannerPreview(
                        action: _selectedAction,
                        overlayText: l10n.foodScannerOverlayAutoDetect,
                        barcodeHint: l10n.foodScannerOverlayBarcodeHint,
                        galleryTitle: l10n.foodScannerGalleryTitle,
                        gallerySubtitle: l10n.foodScannerGallerySubtitle,
                        galleryButtonLabel: l10n.foodScannerGalleryButton,
                        overlayTextStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        onGalleryPick: _openGalleryPicker,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ScannerControls(
                      actions: actions,
                      selectedAction: _selectedAction,
                      onActionSelected: _onActionSelected,
                      onCapture: _onCapturePressed,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
