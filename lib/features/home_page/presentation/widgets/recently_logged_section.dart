import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../food_scanner/domain/entities/scanned_food_entity.dart';
import 'picture_card.dart';

/// Widget to display the Recently logged section with food pictures
class RecentlyLoggedSection extends StatelessWidget {
  final List<ScannedFoodEntity> scannedFoods;
  final VoidCallback? onViewAll;
  final Function(ScannedFoodEntity)? onPictureTap;

  const RecentlyLoggedSection({
    super.key,
    required this.scannedFoods,
    this.onViewAll,
    this.onPictureTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, responsive, localizations),
        SizedBox(height: responsive.height(12)),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(responsive.width(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(responsive.width(16)),
          child: scannedFoods.isEmpty
              ? _buildEmptyState(context, responsive, localizations)
              : _buildPictureGrid(context, responsive),
        ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations?.recentlyLoggedTitle ?? 'Recently logged',
              style: TextStyle(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: responsive.height(4)),
          ],
        ),
        if (scannedFoods.isNotEmpty && onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              localizations?.viewAll ?? 'View all',
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

  Widget _buildEmptyState(
    BuildContext context,
    ResponsiveHelper responsive,
    AppLocalizations? localizations,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.height(32)),
      child: Center(
        child: Text(
          localizations?.recentlyLoggedEmpty ?? 
              'You haven\'t uploaded any food',
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPictureGrid(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: responsive.width(8),
        mainAxisSpacing: responsive.height(8),
        childAspectRatio: 1.0,
      ),
      itemCount: scannedFoods.length > 6 ? 6 : scannedFoods.length,
      itemBuilder: (context, index) {
        final food = scannedFoods[index];
        return PictureCard(
          imagePath: food.imagePath,
          onTap: onPictureTap != null ? () => onPictureTap!(food) : null,
        );
      },
    );
  }
}
