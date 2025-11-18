import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/scanned_food_entity.dart';

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
            onPressed: () => _onShare(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMoreOptions(context, responsive),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildImage(context, responsive))),
          _buildBottomSheet(context, responsive, localizations),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, ResponsiveHelper responsive) {
    if (_isNetworkImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          scannedFood.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              _buildImageError(responsive, 'Error loading image'),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

    final file = File(scannedFood.imagePath);

    if (!file.existsSync()) {
      return _buildImageError(responsive, 'Image not found');
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError(responsive, 'Error loading image');
        },
      ),
    );
  }

  Widget _buildImageError(ResponsiveHelper responsive, String message) {
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

  Widget _buildBottomSheet(
    BuildContext context,
    ResponsiveHelper responsive,
    AppLocalizations? localizations,
  ) {
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
            _getScanTypeTitle(),
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: responsive.height(16)),
          _buildInfoRow(
            context,
            responsive,
            Icons.schedule,
            'Scan time',
            _formatDateTime(scannedFood.scanDate),
          ),
          SizedBox(height: responsive.height(12)),
          _buildInfoRow(
            context,
            responsive,
            Icons.qr_code_scanner,
            'Scan type',
            _getScanTypeLabel(scannedFood.scanType),
          ),
          SizedBox(height: responsive.height(12)),
          _buildInfoRow(
            context,
            responsive,
            Icons.check_circle_outline,
            'Status',
            scannedFood.isProcessed ? 'Processed' : 'Not processed',
          ),
          SizedBox(height: responsive.height(24)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _onDelete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(localizations?.delete ?? 'Delete'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.height(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive.width(12)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.width(12)),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => _onAnalyze(context),
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(localizations?.analyzeFood ?? 'Analyze Food'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.height(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive.width(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    ResponsiveHelper responsive,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: responsive.fontSize(20), color: Colors.grey.shade600),
        SizedBox(width: responsive.width(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getScanTypeTitle() {
    switch (scannedFood.scanType) {
      case ScanType.food:
        return 'Food Photo';
      case ScanType.barcode:
        return 'Barcode Scan';
      case ScanType.gallery:
        return 'Gallery Image';
    }
  }

  String _getScanTypeLabel(ScanType scanType) {
    switch (scanType) {
      case ScanType.food:
        return 'Food Camera';
      case ScanType.barcode:
        return 'Barcode Scanner';
      case ScanType.gallery:
        return 'From Gallery';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    }
  }

  void _onShare(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
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
              leading: const Icon(Icons.info_outline),
              title: const Text('Image details'),
              onTap: () {
                Navigator.pop(context);
                _showImageDetails(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDetails(BuildContext context) {
    if (_isNetworkImage) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Image Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Image URL:\n${scannedFood.imagePath}'),
              const SizedBox(height: 12),
              Text(
                'Scan date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(scannedFood.scanDate)}',
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
        ),
      );
      return;
    }

    final file = File(scannedFood.imagePath);
    final fileSize = file.existsSync() ? file.lengthSync() : 0;
    final fileSizeKB = (fileSize / 1024).toStringAsFixed(2);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              'Scan date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(scannedFood.scanDate)}',
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
      ),
    );
  }

  bool get _isNetworkImage {
    final uri = Uri.tryParse(scannedFood.imagePath);
    return uri != null && uri.hasScheme;
  }

  void _onDelete(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.deletePhoto ?? 'Delete Photo'),
        content: Text(
          localizations?.deletePhotoConfirmation ??
              'Are you sure you want to delete this photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  void _onAnalyze(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
