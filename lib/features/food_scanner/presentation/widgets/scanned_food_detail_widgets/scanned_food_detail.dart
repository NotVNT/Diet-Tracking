import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';
import 'delete_confirmation_dialog.dart';
import 'image_viewer_widget.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../../record_view_home/presentation/cubit/record_cubit.dart';

/// Page to display scanned food details with image viewer and actions
class ScannedFoodDetailPage extends StatelessWidget {
  final FoodRecordEntity scannedFood;

  const ScannedFoodDetailPage({super.key, required this.scannedFood});

  @override
  Widget build(BuildContext context) {
    final isBarcode = scannedFood.recordType == RecordType.barcode;

    return isBarcode
        ? _buildBarcodeView(context)
        : _buildImageView(context);
  }

  Widget _buildImageView(BuildContext context) {
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
          _DetailBottomSheetWidget(
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          localizations?.selectedFood ?? 'Selected food',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () => _onShare(context, localizations),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showMoreOptions(context, responsive),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(responsive.width(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scannedFood.foodName.isNotEmpty ? scannedFood.foodName : 'No Food Detected',
              style: TextStyle(
                fontSize: responsive.fontSize(28),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.height(24)),
            _CalorieInfoCard(
              calories: scannedFood.calories,
              responsive: responsive,
            ),
            SizedBox(height: responsive.height(16)),
            Row(
              children: [
                _NutrientInfoCard(
                  label: 'Protein',
                  value: scannedFood.protein,
                  color: Colors.red.shade100,
                  icon: Icons.kebab_dining,
                  responsive: responsive,
                ),
                _NutrientInfoCard(
                  label: 'Carbs',
                  value: scannedFood.carbs,
                  color: Colors.green.shade100,
                  icon: Icons.grain,
                  responsive: responsive,
                ),
                _NutrientInfoCard(
                  label: 'Fat',
                  value: scannedFood.fat,
                  color: Colors.blue.shade100,
                  icon: Icons.opacity,
                  responsive: responsive,
                ),
              ],
            ),
          ],
        ),
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
      builder: (bottomSheetContext) => _MoreOptionsMenu(
        scannedFood: scannedFood,
        responsive: responsive,
        onDelete: () {
          Navigator.pop(bottomSheetContext); // Dismiss the bottom sheet
          _onDelete(context); // Call the delete function
        },
      ),
    );
  }

  void _onDelete(BuildContext context) async {
    final recordCubit = context.read<RecordCubit>();
    final bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );

    if (shouldDelete == true && scannedFood.id != null) {
      // Use the cubit to delete the record
      recordCubit.deleteFoodRecord(scannedFood.id!);
      // Pop the detail page and return true to notify the home page
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

}

/// Bottom sheet widget displaying scanned food details and action buttons
class _DetailBottomSheetWidget extends StatelessWidget {
  final FoodRecordEntity scannedFood;
  final ResponsiveHelper responsive;

  const _DetailBottomSheetWidget({
    required this.scannedFood,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            scannedFood.foodName.isNotEmpty ? scannedFood.foodName : 'No Food Detected',
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: responsive.height(24)),
          _CalorieInfoCard(
            calories: scannedFood.calories,
            responsive: responsive,
          ),
          SizedBox(height: responsive.height(16)),
          Row(
            children: [
              _NutrientInfoCard(
                label: 'Protein',
                value: scannedFood.protein,
                color: Colors.red.shade100,
                icon: Icons.kebab_dining, 
                responsive: responsive,
              ),
              _NutrientInfoCard(
                label: 'Carbs',
                value: scannedFood.carbs,
                color: Colors.green.shade100,
                icon: Icons.grain, 
                responsive: responsive,
              ),
              _NutrientInfoCard(
                label: 'Fat',
                value: scannedFood.fat,
                color: Colors.blue.shade100,
                icon: Icons.opacity, 
                responsive: responsive,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet menu showing more options for the scanned food detail
class _MoreOptionsMenu extends StatelessWidget {
  final FoodRecordEntity scannedFood;
  final ResponsiveHelper responsive;
  final VoidCallback onDelete;

  const _MoreOptionsMenu({
    required this.scannedFood,
    required this.responsive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Ask chat bot'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Save to device'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}


class _CalorieInfoCard extends StatelessWidget {
  final double calories;
  final ResponsiveHelper responsive;

  const _CalorieInfoCard({required this.calories, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.width(16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(responsive.width(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            size: responsive.fontSize(32),
            color: Colors.orange,
          ),
          SizedBox(width: responsive.width(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${calories.toStringAsFixed(0)}kcal',
                style: TextStyle(
                  fontSize: responsive.fontSize(24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Calories',
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutrientInfoCard extends StatelessWidget {
  final String label;
  final double? value;
  final Color color;
  final IconData icon;
  final ResponsiveHelper responsive;

  const _NutrientInfoCard({
    required this.label,
    this.value,
    required this.color,
    required this.icon,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: responsive.width(4)),
        padding: EdgeInsets.all(responsive.width(12)),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(responsive.width(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: responsive.fontSize(24), color: Colors.black87),
            SizedBox(height: responsive.height(8)),
            Text(
              '${value?.toStringAsFixed(0) ?? 'N/A'}g',
              style: TextStyle(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}