import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/common/snackbar_helper.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';

class FoodAnalysisCard extends StatelessWidget {
  final FoodRecordEntity foodRecord;
  // Optional callbacks for actions to keep presentation layer clean
  final void Function(FoodRecordEntity record)? onAskChatBot;
  final void Function(FoodRecordEntity record)? onDelete;

  const FoodAnalysisCard({
    super.key,
    required this.foodRecord,
    this.onAskChatBot,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder data for macros as it's not in the entity
    const double protein = 6.0;
    const double carbs = 50.0;
    const double fat = 15.0;

    final theme = Theme.of(context);

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
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          _buildFoodImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitleTimeAndActions(context),
                const SizedBox(height: 6),
                _buildCaloriesInfo(context),
                const SizedBox(height: 10),
                _buildMacrosRow(protein, carbs, fat),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: foodRecord.imagePath != null
          ? Image.network(
              foodRecord.imagePath!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 100,
      width: 100,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
    );
  }

  Widget _buildTitleTimeAndActions(BuildContext context) {
    final timeText = Text(
      DateFormat('HH:mm').format(foodRecord.date),
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF999999),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            foodRecord.foodName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        const SizedBox(width: 8),
        timeText,
        const SizedBox(width: 8),
        _CardActionsMenu(
          record: foodRecord,
          onAskChatBot: onAskChatBot,
          onDelete: onDelete,
        ),
      ],
    );
  }

  Widget _buildCaloriesInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.local_fire_department, color: Color(0xFFFF3B30), size: 24),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: foodRecord.calories.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const TextSpan(
                text: ' kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacrosRow(double protein, double carbs, double fat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MacroInfo(icon: Icons.egg, color: const Color(0xFF4CAF50), value: protein, unit: 'g', name: 'Protein'),
        _MacroInfo(icon: Icons.bakery_dining, color: const Color(0xFF2196F3), value: carbs, unit: 'g', name: 'Carbs'),
        _MacroInfo(icon: Icons.oil_barrel, color: const Color(0xFFFFC107), value: fat, unit: 'g', name: 'Fat'),
      ],
    );
  }
}

class _MacroInfo extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double value;
  final String unit;
  final String name;

  const _MacroInfo({
    required this.icon,
    required this.color,
    required this.value,
    required this.unit,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: value.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Available actions for the FoodAnalysisCard menu
enum _FoodCardAction {
  askChatBot,
  delete,
}


/// Actions menu for FoodAnalysisCard
class _CardActionsMenu extends StatelessWidget {
  final FoodRecordEntity record;
  final void Function(FoodRecordEntity record)? onAskChatBot;
  final void Function(FoodRecordEntity record)? onDelete;

  const _CardActionsMenu({
    required this.record,
    this.onAskChatBot,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<_FoodCardAction>(
      tooltip: 'Actions',
      onSelected: (action) => _handleAction(context, action),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) => [
        PopupMenuItem<_FoodCardAction>(
          value: _FoodCardAction.askChatBot,
          child: _MenuRow(icon: Icons.smart_toy, color: theme.colorScheme.primary, label: l10n.bottomNavChatBot),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<_FoodCardAction>(
          value: _FoodCardAction.delete,
          child: _MenuRow(icon: Icons.delete_outline, color: const Color(0xFFFF3B30), label: l10n.delete),
        ),
      ],
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
        ),
        child: Icon(Icons.more_vert, color: theme.colorScheme.primary),
      ),
    );
  }

  void _handleAction(BuildContext context, _FoodCardAction action) {
    switch (action) {
      case _FoodCardAction.askChatBot:
        if (onAskChatBot != null) {
          onAskChatBot!(record);
        } else {
          // Fallback info if no handler provided
          SnackBarHelper.showInfo(context, AppLocalizations.of(context)!.profileFeatureInDevelopment);
        }
        break;
      case _FoodCardAction.delete:
        if (onDelete != null) {
          onDelete!(record);
        } else {
          SnackBarHelper.showInfo(context, AppLocalizations.of(context)!.profileFeatureInDevelopment);
        }
        break;
    }
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MenuRow({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

