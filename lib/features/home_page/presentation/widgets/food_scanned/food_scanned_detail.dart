// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../common/snackbar_helper.dart';
import '../../../../../common/app_confirm_dialog.dart';

import 'food_image_widget.dart';
import 'food_scanned_info.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../shared/options_menu_for_plus_button.dart';

/// Page to display scanned food details with image viewer and actions
class ScannedFoodDetailPage extends StatelessWidget {
  final FoodRecordEntity scannedFood;

  const ScannedFoodDetailPage({super.key, required this.scannedFood});

  @override
  Widget build(BuildContext context) {
    final isBarcode = scannedFood.recordType == RecordType.barcode;

    return isBarcode ? _buildBarcodeView(context) : _buildImageView(context);
  }

  Widget _buildImageView(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
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
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeView(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          localizations?.selectedFood ?? 'Selected food',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onPressed: () => _showMoreOptions(context, responsive),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(responsive.width(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoodScannedInfo(
              record: scannedFood,
              showTime: true,
              emphasizeCalories: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, ResponsiveHelper responsive) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) => MoreOptionsMenu(
        scannedFood: scannedFood,
        responsive: responsive,
        onDelete: () {
          // Bottom sheet will be closed inside MoreOptionsMenu after confirmation
          _onDelete(context);
        },
        showSaveToDevice: scannedFood.recordType != RecordType.barcode,
        // Close this detail page after choosing Ask chat bot to reveal main scaffold
        onCloseParent: () {
          final nav = Navigator.of(context);
          if (nav.canPop()) nav.pop();
        },
      ),
    );
  }

  void _onDelete(BuildContext context) async {
    final recordCubit = context.read<RecordCubit>();
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final id = scannedFood.id;
    if (id == null) {
      SnackBarHelper.showError(context, l10n?.snackbarErrorTitle ?? 'Error');
      return;
    }

    // Show only one confirmation: "Xóa món ăn"
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n?.deleteMealTitle ?? 'Xoá món ăn?',
      message:
          l10n?.deleteMealMessage(scannedFood.foodName) ??
          'Bạn có chắc muốn xoá "${scannedFood.foodName}" khỏi ghi nhận?',
      confirmText: l10n?.delete,
      cancelText: l10n?.cancel,
      destructive: true,
      icon: Icons.delete_rounded,
    );
    if (confirmed != true) return;

    await recordCubit.deleteFoodRecord(id);
    if (!context.mounted) return;
    SnackBarHelper.showSuccess(
      context,
      l10n?.photoDeletedSuccessfully ?? 'Deleted successfully',
    );
    if (navigator.canPop()) {
      navigator.pop(true);
    }
  }
}

/// Bottom sheet widget displaying scanned food details and action buttons
class DetailBottomSheetWidget extends StatelessWidget {
  final FoodRecordEntity scannedFood;
  final ResponsiveHelper responsive;

  const DetailBottomSheetWidget({
    super.key,
    required this.scannedFood,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.width(24)),
        ),
      ),
      padding: EdgeInsets.all(responsive.width(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: responsive.width(40),
              height: 4,
              margin: EdgeInsets.only(bottom: responsive.height(16)),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.onSurface.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          FoodScannedInfo(
            record: scannedFood,
            showTime: true,
            emphasizeCalories: true,
          ),
        ],
      ),
    );
  }
}
