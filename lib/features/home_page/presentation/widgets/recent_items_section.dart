import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';
import 'picture_card.dart';
import 'meal_list_item.dart';

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

  Widget _buildPhotoSection(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(responsive.width(16)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(responsive.width(16)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: responsive.width(8),
          mainAxisSpacing: responsive.height(8),
          childAspectRatio: 1.0,
        ),
        itemCount: photoItems.length > 6 ? 6 : photoItems.length,
        itemBuilder: (context, index) {
          final food = photoItems[index];
          return PictureCard(
            imagePath: food.imagePath,
            foodName: food.foodName,
            calories: food.calories,
            recordType: food.recordType,
            onTap: onItemTap != null ? () => onItemTap!(food) : null,
          );
        },
      ),
    );
  }

  Widget _buildBarcodeSection(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: barcodeItems.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: responsive.height(8)),
      itemBuilder: (context, index) {
        final food = barcodeItems[index];
        return MealListItem(
          food: food,
          onTap: onItemTap != null ? () => onItemTap!(food) : null,
        );
      },
    );
  }
}
