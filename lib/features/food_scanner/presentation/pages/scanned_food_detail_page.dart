import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/scanned_food_entity.dart';
import '../widgets/scanned_food_detail_widgets/image_viewer_widget.dart';
import '../widgets/scanned_food_detail_widgets/detail_bottom_sheet_widget.dart';
import '../widgets/scanned_food_detail_widgets/more_options_menu.dart';
import '../widgets/scanned_food_detail_widgets/delete_confirmation_dialog.dart';

/// Page to display scanned food details with image viewer and actions
class ScannedFoodDetailPage extends StatelessWidget {
  final ScannedFoodEntity scannedFood;

  const ScannedFoodDetailPage({super.key, required this.scannedFood});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _onShare(context, localizations),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMoreOptions(context, responsive),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ImageViewerWidget(
                imagePath: scannedFood.imagePath,
                responsive: responsive,
              ),
            ),
          ),
          DetailBottomSheetWidget(
            scannedFood: scannedFood,
            responsive: responsive,
            onDelete: () => _onDelete(context),
            onAnalyze: () => _onAnalyze(context, localizations),
          ),
        ],
      ),
    );
  }

  void _onShare(BuildContext context, AppLocalizations? localizations) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizations?.shareFunctionality ??
              'Share functionality coming soon',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreOptions(BuildContext context, ResponsiveHelper responsive) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => MoreOptionsMenu(
        scannedFood: scannedFood,
        responsive: responsive,
      ),
    );
  }

  void _onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );
  }

  void _onAnalyze(BuildContext context, AppLocalizations? localizations) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizations?.aiFoodAnalysis ?? 'AI food analysis coming soon',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
