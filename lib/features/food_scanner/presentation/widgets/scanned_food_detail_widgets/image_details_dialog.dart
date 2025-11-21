import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/scanned_food_entity.dart';
import 'date_time_formatter.dart';

/// Dialog to display detailed information about the scanned image
class ImageDetailsDialog extends StatelessWidget {
  final ScannedFoodEntity scannedFood;

  const ImageDetailsDialog({
    super.key,
    required this.scannedFood,
  });

  @override
  Widget build(BuildContext context) {
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
            'Scan date: ${DateTimeFormatter.formatFullDateTime(scannedFood.scanDate)}',
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
    final file = File(scannedFood.imagePath);
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
            'Scan date: ${DateTimeFormatter.formatFullDateTime(scannedFood.scanDate)}',
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

  bool get _isNetworkImage {
    final uri = Uri.tryParse(scannedFood.imagePath);
    return uri != null && uri.hasScheme;
  }
}

