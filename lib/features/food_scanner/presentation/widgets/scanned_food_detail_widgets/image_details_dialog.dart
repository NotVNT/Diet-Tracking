import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import 'date_time_formatter.dart';

/// Dialog to display detailed information about the scanned image
class ImageDetailsDialog extends StatelessWidget {
  final FoodRecordEntity scannedFood;

  const ImageDetailsDialog({super.key, required this.scannedFood});

  @override
  Widget build(BuildContext context) {
    if (scannedFood.imagePath == null || scannedFood.imagePath!.isEmpty) {
      return _buildNoImageDialog(context);
    }

    if (_isNetworkImage) {
      return _buildNetworkImageDialog(context);
    }

    return _buildLocalImageDialog(context);
  }

  Widget _buildNetworkImageDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Image Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Image URL:\n${scannedFood.imagePath}'),
          const SizedBox(height: 12),
          Text(
            'Date: ${DateTimeFormatter.formatFullDateTime(scannedFood.date)}',
          ),
          const SizedBox(height: 12),
          Text('ID: ${scannedFood.id}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildLocalImageDialog(BuildContext context) {
    final file = File(scannedFood.imagePath!);
    final fileSize = file.existsSync() ? file.lengthSync() : 0;
    final fileSizeKB = (fileSize / 1024).toStringAsFixed(2);

    return AlertDialog(
      title: const Text('Image Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('File path:\n${scannedFood.imagePath}'),
          const SizedBox(height: 12),
          Text('File size: $fileSizeKB KB'),
          const SizedBox(height: 12),
          Text(
            'Date: ${DateTimeFormatter.formatFullDateTime(scannedFood.date)}',
          ),
          const SizedBox(height: 12),
          Text('ID: ${scannedFood.id}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildNoImageDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Details'),
      content: Text('This item has no associated image.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  bool get _isNetworkImage {
    if (scannedFood.imagePath == null) return false;
    final uri = Uri.tryParse(scannedFood.imagePath!);
    return uri != null && uri.hasScheme;
  }
}
