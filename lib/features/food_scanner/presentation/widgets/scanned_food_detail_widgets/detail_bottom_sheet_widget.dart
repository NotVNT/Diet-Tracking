import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/scanned_food_entity.dart';
import 'info_row_widget.dart';
import 'scan_type_helper.dart';
import 'date_time_formatter.dart';

/// Bottom sheet widget displaying scanned food details and action buttons
class DetailBottomSheetWidget extends StatelessWidget {
  final ScannedFoodEntity scannedFood;
  final ResponsiveHelper responsive;
  final VoidCallback onDelete;
  final VoidCallback onAnalyze;

  const DetailBottomSheetWidget({
    super.key,
    required this.scannedFood,
    required this.responsive,
    required this.onDelete,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
            ScanTypeHelper.getScanTypeTitle(scannedFood.scanType),
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: responsive.height(16)),
          InfoRowWidget(
            icon: Icons.schedule,
            label: 'Scan time',
            value: DateTimeFormatter.formatRelativeTime(scannedFood.scanDate),
            responsive: responsive,
          ),
          SizedBox(height: responsive.height(12)),
          InfoRowWidget(
            icon: Icons.qr_code_scanner,
            label: 'Scan type',
            value: ScanTypeHelper.getScanTypeLabel(scannedFood.scanType),
            responsive: responsive,
          ),
          SizedBox(height: responsive.height(12)),
          InfoRowWidget(
            icon: Icons.check_circle_outline,
            label: 'Status',
            value: scannedFood.isProcessed ? 'Processed' : 'Not processed',
            responsive: responsive,
          ),
          SizedBox(height: responsive.height(24)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
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
                  onPressed: onAnalyze,
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
}

