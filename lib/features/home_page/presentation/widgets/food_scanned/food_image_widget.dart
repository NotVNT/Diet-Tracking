import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';

/// Widget to display an image with zoom and pan capabilities
class ImageViewerWidget extends StatelessWidget {
  final String? imagePath;
  final ResponsiveHelper responsive;

  const ImageViewerWidget({
    super.key,
    required this.imagePath,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildImageError('No image available');
    }

    if (_isNetworkImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          imagePath!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildImageError('Error loading image'),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

    final file = File(imagePath!);

    if (!file.existsSync()) {
      return _buildImageError('Image not found');
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError('Error loading image');
        },
      ),
    );
  }

  Widget _buildImageError(String message) {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: responsive.width(80),
              color: Colors.white54,
            ),
            SizedBox(height: responsive.height(16)),
            Text(
              message,
              style: TextStyle(
                color: Colors.white54,
                fontSize: responsive.fontSize(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isNetworkImage {
    if (imagePath == null) return false;
    final uri = Uri.tryParse(imagePath!);
    return uri != null && uri.hasScheme;
  }
}
