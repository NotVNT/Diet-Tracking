import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';

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
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
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
                hintText:
                    hintText ?? localizations?.searchHintText ?? 'Tìm kiếm',
                hintStyle: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: responsive.iconSize(20),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
      ],
    );
  }
}
