import 'package:flutter/material.dart';
import '../shared/plus_button.dart';
import 'food_scanned_info.dart';
import '../shared/options_menu_for_plus_button.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../utils/performance_utils.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';

class FoodScannedCard extends StatelessWidget {
  final FoodRecordEntity foodRecord;
  // Optional callbacks for actions to keep presentation layer clean
  final void Function(FoodRecordEntity record)? onAskChatBot;
  final void Function(FoodRecordEntity record)? onDelete;
  final void Function(FoodRecordEntity record)? onAdd;
  // Cho phép ẩn nút Add ở các danh sách không cần
  final bool showAddButton;

  const FoodScannedCard({
    super.key,
    required this.foodRecord,
    this.onAskChatBot,
    this.onDelete,
    this.onAdd,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isBarcode = foodRecord.recordType == RecordType.barcode;
    final bool showImage = !isBarcode && foodRecord.imagePath != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showImage) ...[_buildFoodImage(), const SizedBox(width: 12)],
          Expanded(
            child: FoodScannedInfo(
              record: foodRecord,
              showTime: true,
              emphasizeCalories: true,
            ),
          ),
          if (showAddButton || isBarcode) ...[
            const SizedBox(width: 8),
            _buildAddButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodImage() {
    // Sử dụng Container với decoration thay vì ClipRRect để giảm layer overhead
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: PerformanceUtils.buildCachedImage(
          imageUrl: foodRecord.imagePath!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return AddBadgeIconButton(
      onPressed: () => _showMoreOptions(context),
      size: 36,
      borderRadius: 8,
      semanticLabel: 'add-scanned-item',
      tooltip: 'More options',
    );
  }

  void _showMoreOptions(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) => MoreOptionsMenu(
        scannedFood: foodRecord,
        responsive: responsive,
        // Let MoreOptionsMenu handle confirmation + closing the sheet.
        onDelete: () {
          onDelete?.call(foodRecord);
        },
        showSaveToDevice: false,
      ),
    );
  }
}
