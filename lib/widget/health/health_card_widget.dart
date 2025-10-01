import 'package:flutter/material.dart';
import '../../common/app_colors.dart';
import '../../common/app_styles.dart';

class HealthCardWidget extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final Widget input;
  final Widget trailingButton;
  final IconData emptyIcon;
  final String emptyText;
  final List<String> items;
  final void Function(int index)? onRemoveItem;

  const HealthCardWidget({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.input,
    required this.trailingButton,
    required this.emptyIcon,
    required this.emptyText,
    this.items = const [],
    this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IndexBadge(index: index),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.heading2.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(description, style: AppStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: input),
              const SizedBox(width: 8),
              trailingButton,
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(emptyIcon, color: AppColors.grey400),
                  const SizedBox(height: 6),
                  Text(
                    emptyText,
                    style: AppStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < items.length; i++)
                  _RemovableChip(
                    label: items[i],
                    onRemoved: onRemoveItem == null
                        ? null
                        : () => onRemoveItem!(i),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _IndexBadge extends StatelessWidget {
  final int index;
  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF0FB5A6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        index.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemoved;
  const _RemovableChip({required this.label, this.onRemoved});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: AppStyles.bodySmall),
      onDeleted: onRemoved,
      deleteIcon: onRemoved == null ? null : const Icon(Icons.close, size: 16),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
