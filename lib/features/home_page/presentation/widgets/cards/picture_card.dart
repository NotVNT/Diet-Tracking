import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';

/// Widget to display a single picture card in the recently logged section
class PictureCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback? onTap;
  final String? foodName;
  final double? calories;
  final RecordType? recordType;

  const PictureCard({
    super.key,
    required this.imagePath,
    this.onTap,
    this.foodName,
    this.calories,
    this.recordType,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);

    // Check xem có phải barcode không có ảnh không
    final isBarcodeWithoutImage =
        recordType == RecordType.barcode &&
        (imagePath == null || imagePath!.trim().isEmpty);

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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Nếu là barcode không có ảnh, hiển thị card thông tin
              if (isBarcodeWithoutImage)
                _buildBarcodeCard(context, responsive)
              else
                _buildImageContent(context),
              // Overlay cho barcode items có ảnh
              if (recordType == RecordType.barcode &&
                  !isBarcodeWithoutImage &&
                  (foodName != null || calories != null))
                _buildBarcodeOverlay(context, responsive),
            ],
          ),
        ),
      ),
    );
  }

  /// Card đặc biệt cho barcode (không có ảnh)
  Widget _buildBarcodeCard(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      padding: EdgeInsets.all(responsive.width(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: responsive.width(32),
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: responsive.height(4)),
          if (foodName != null)
            Text(
              foodName!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.fontSize(11),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          if (calories != null)
            Padding(
              padding: EdgeInsets.only(top: responsive.height(2)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.width(8),
                  vertical: responsive.height(2),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.width(12)),
                ),
                child: Text(
                  '🔥 ${calories!.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: responsive.fontSize(10),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBarcodeOverlay(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.width(6),
          vertical: responsive.height(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (foodName != null)
              Text(
                foodName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: responsive.fontSize(10),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            if (calories != null)
              Text(
                '${calories!.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: responsive.fontSize(9),
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder(context);
    }

    if (_isNetworkImage) {
      return Image.network(
        imagePath!,
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

    final file = File(imagePath!);

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
    if (imagePath == null) return false;
    final uri = Uri.tryParse(imagePath!);
    return uri != null && uri.hasScheme;
  }
}
