import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../responsive/responsive.dart';

/// Widget thanh tìm kiếm với nút lọc
class SearchFilterBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTapped;
  final String? hintText;
  final bool showFilterButton;

  const SearchFilterBar({
    super.key,
    this.controller,
    this.onSearchChanged,
    this.onFilterTapped,
    this.hintText,
    this.showFilterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        // Search field
        Expanded(
          child: Container(
            height: responsive.height(48),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(responsive.radius(12)),
            ),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText ?? localizations?.searchHint ?? 'Tìm kiếm',
                hintStyle: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: responsive.iconSize(20),
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: responsive.width(16),
                  vertical: responsive.height(12),
                ),
              ),
            ),
          ),
        ),
        
        // Filter button
        if (showFilterButton) ...[
          SizedBox(width: responsive.width(12)),
          InkWell(
            onTap: onFilterTapped,
            borderRadius: BorderRadius.circular(responsive.radius(12)),
            child: Container(
              height: responsive.height(48),
              width: responsive.width(48),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
              child: Icon(
                Icons.tune,
                size: responsive.iconSize(24),
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
