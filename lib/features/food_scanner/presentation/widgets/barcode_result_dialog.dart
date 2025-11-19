import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Widget hiển thị kết quả quét barcode
class BarcodeResultDialog extends StatelessWidget {
  final List<Barcode> barcodes;
  final String imagePath;
  final VoidCallback onClose;
  final Function(Barcode) onBarcodeSelected;

  const BarcodeResultDialog({
    super.key,
    required this.barcodes,
    required this.imagePath,
    required this.onClose,
    required this.onBarcodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đã tìm thấy ${barcodes.length} mã',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: barcodes.isEmpty
                  ? _buildEmptyState()
                  : _buildBarcodeList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy mã nào',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: barcodes.length,
      separatorBuilder: (_, __) => const Divider(
        color: Colors.white12,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final barcode = barcodes[index];
        return _buildBarcodeItem(context, barcode, index);
      },
    );
  }

  Widget _buildBarcodeItem(BuildContext context, Barcode barcode, int index) {
    final displayValue = barcode.displayValue ?? barcode.rawValue ?? 'N/A';
    final type = _getBarcodeTypeName(barcode.format);

    return InkWell(
      onTap: () {
        onBarcodeSelected(barcode);
        onClose();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayValue,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type,
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
              onPressed: () => _copyToClipboard(context, displayValue),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép: $text'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getBarcodeTypeName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.upca:
        return 'UPC-A';
      case BarcodeFormat.upce:
        return 'UPC-E';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.code93:
        return 'Code 93';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.aztec:
        return 'Aztec';
      case BarcodeFormat.codabar:
        return 'Codabar';
      case BarcodeFormat.itf:
        return 'ITF';
      default:
        return 'Unknown';
    }
  }
}
