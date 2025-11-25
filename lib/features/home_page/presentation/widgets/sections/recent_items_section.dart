import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../components/meal_list_item.dart';
import '../cards/food_analysis_card.dart';

/// Widget to display recently logged photos and barcode scans
class RecentItemsSection extends StatelessWidget {
  final List<FoodRecordEntity> photoItems;
  final List<FoodRecordEntity> barcodeItems;
  final VoidCallback? onViewAllPhotos;
  final Function(FoodRecordEntity)? onItemTap;

  const RecentItemsSection({
    super.key,
    required this.photoItems,
    required this.barcodeItems,
    this.onViewAllPhotos,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);
    final bool showPhotos = photoItems.isNotEmpty;
    final bool showBarcodes = barcodeItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, responsive, localizations),
        SizedBox(height: responsive.height(12)),
        if (showPhotos) _buildPhotoSection(context, responsive),
        if (showPhotos && showBarcodes)
          SizedBox(height: responsive.height(16)), // Spacer between sections
        if (showBarcodes) _buildBarcodeSection(context, responsive),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ResponsiveHelper responsive,
    AppLocalizations? localizations,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations?.recentlyLoggedTitle ?? 'Đã ghi nhận gần đây',
          style: TextStyle(
            fontSize: responsive.fontSize(18),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (photoItems.isNotEmpty && onViewAllPhotos != null)
          GestureDetector(
            onTap: onViewAllPhotos,
            child: Text(
              localizations?.viewAll ?? 'Xem tất cả',
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoSection(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return Column(
      children: List.generate(
        photoItems.length * 2 - 1,
        (index) {
          if (index.isOdd) {
            return SizedBox(height: responsive.height(16));
          }
          final foodIndex = index ~/ 2;
          final food = photoItems[foodIndex];
          return GestureDetector(
            onTap: onItemTap != null ? () => onItemTap!(food) : null,
            child: FoodAnalysisCard(foodRecord: food),
          );
        },
      ),
    );
  }

  Widget _buildBarcodeSection(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return Column(
      children: List.generate(
        barcodeItems.length * 2 - 1,
        (index) {
          if (index.isOdd) {
            return SizedBox(height: responsive.height(8));
          }
          final foodIndex = index ~/ 2;
          final food = barcodeItems[foodIndex];
          return MealListItem(
            food: food,
            onTap: onItemTap != null ? () => onItemTap!(food) : null,
          );
        },
      ),
    );
  }
}
