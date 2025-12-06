import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../food_scanned/food_scanned_card.dart';
import '../shared/empty_state_card.dart';

/// Widget to display recently logged photos and barcode scans
class RecentlyLoggedSection extends StatelessWidget {
  final List<FoodRecordEntity> photoItems;
  final List<FoodRecordEntity> barcodeItems;
  final VoidCallback? onViewAllPhotos;
  final Function(FoodRecordEntity)? onItemTap;
  final Function(FoodRecordEntity)? onDelete;

  /// Optional subtitle for empty state. If null, localized default text is used.
  final String? emptySubtitle;
  final VoidCallback? onEmptyTap;

  /// Show a hint line like: "You have more logs — tap View All to see more."
  final bool showMoreHint;

  /// Customizable hint text. If null, a localized default is used.
  final String? moreHintText;

  const RecentlyLoggedSection({
    super.key,
    required this.photoItems,
    required this.barcodeItems,
    this.onViewAllPhotos,
    this.onItemTap,
    this.onDelete,
    this.emptySubtitle,
    this.onEmptyTap,
    this.showMoreHint = false,
    this.moreHintText,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);
    final bool showPhotos = photoItems.isNotEmpty;
    final bool showBarcodes = barcodeItems.isNotEmpty;
    final bool hasAny = showPhotos || showBarcodes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, responsive, localizations, hasAny),
        SizedBox(height: responsive.height(12)),
        if (!hasAny)
          EmptyStateCard(
            title:
                localizations?.recentlyLoggedEmpty ??
                "You haven't uploaded any food",
            subtitle:
                emptySubtitle ??
                (localizations?.recentlyLoggedSubtitle ??
                    'Start tracking your meals by taking a quick picture'),
            onTap: onEmptyTap,
          )
        else ...[
          if (showPhotos) _buildPhotoSection(context, responsive),
          if (showPhotos && showBarcodes)
            SizedBox(height: responsive.height(16)), // Spacer between sections
          if (showBarcodes) _buildBarcodeSection(context, responsive),
          if (showMoreHint) ...[
            SizedBox(height: responsive.height(12)),
            Text(
              moreHintText ?? _defaultMoreHint(localizations),
              style: TextStyle(
                fontSize: responsive.fontSize(13),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ],
    );
  }

  String _defaultMoreHint(AppLocalizations? l10n) {
    final isVi = (l10n?.localeName ?? '').startsWith('vi');
    final viewAll = l10n?.viewAll ?? (isVi ? 'Xem tất cả' : 'View all');
    return isVi
        ? 'Bạn còn nhiều bản ghi — nhấn $viewAll để xem thêm.'
        : 'You have more logs — tap $viewAll to see more.';
  }

  Widget _buildHeader(
    BuildContext context,
    ResponsiveHelper responsive,
    AppLocalizations? localizations,
    bool hasAny,
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
        if (hasAny && onViewAllPhotos != null)
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
    return Column(
      children: List.generate(photoItems.length * 2 - 1, (index) {
        if (index.isOdd) {
          return SizedBox(height: responsive.height(16));
        }
        final foodIndex = index ~/ 2;
        final food = photoItems[foodIndex];
        return GestureDetector(
          onTap: onItemTap != null ? () => onItemTap!(food) : null,
          child: FoodScannedCard(foodRecord: food, onDelete: onDelete),
        );
      }),
    );
  }

  Widget _buildBarcodeSection(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return Column(
      children: List.generate(barcodeItems.length * 2 - 1, (index) {
        if (index.isOdd) {
          return SizedBox(height: responsive.height(8));
        }
        final foodIndex = index ~/ 2;
        final food = barcodeItems[foodIndex];
        return GestureDetector(
          onTap: onItemTap != null ? () => onItemTap!(food) : null,
          child: FoodScannedCard(foodRecord: food, onDelete: onDelete),
        );
      }),
    );
  }
}
