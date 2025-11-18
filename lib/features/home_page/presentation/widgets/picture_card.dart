import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';

/// Widget to display a single picture card in the recently logged section
class PictureCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const PictureCard({super.key, required this.imagePath, this.onTap});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsive.width(12)),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(responsive.width(12)),
          child: _buildImageContent(context),
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (_isNetworkImage) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildPlaceholder(context, showLoader: true);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    }

    final file = File(imagePath);

    // Check if file exists
    if (!file.existsSync()) {
      return _buildPlaceholder(context);
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(context);
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context, {bool showLoader = false}) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Center(
        child: showLoader
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.image_outlined,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 32,
              ),
      ),
    );
  }

  bool get _isNetworkImage {
    final uri = Uri.tryParse(imagePath);
    return uri != null && uri.hasScheme;
  }
}
