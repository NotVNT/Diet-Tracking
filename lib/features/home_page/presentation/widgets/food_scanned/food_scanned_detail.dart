// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';

import 'food_image_widget.dart';
import 'food_scanned_info.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../components/more_options_menu.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) => MoreOptionsMenu(
        scannedFood: scannedFood,
        responsive: responsive,
        onDelete: () {
          Navigator.pop(bottomSheetContext); // Dismiss the bottom sheet
          _onDelete(context); // Call the delete function
        },
        showSaveToDevice: scannedFood.recordType != RecordType.barcode,
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
