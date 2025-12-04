import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../common/app_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/food_record_entity.dart';

abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object> get props => [];
}

class RecordInitial extends RecordState {}

class RecordLoading extends RecordState {}

class RecordSuccess extends RecordState {
  final String message;

  const RecordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class RecordError extends RecordState {
  final String message;

  const RecordError(this.message);

  @override
  List<Object> get props => [message];
}

class RecordListLoaded extends RecordState {
  final List<FoodRecordEntity> records;
  final List<FoodRecordEntity> filteredRecords;

  const RecordListLoaded(this.records, {List<FoodRecordEntity>? filteredRecords})
      : filteredRecords = filteredRecords ?? records;

  @override
  List<Object> get props => [records, filteredRecords];
}


class RecordErrorWidget extends StatelessWidget {
  const RecordErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppStyles.bodyMedium.copyWith(color: colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(l10n?.retryButton ?? 'Thử lại'),
          ),
        ],
      ),
    );
  }
}

class RecordEmptyStateWidget extends StatelessWidget {
  const RecordEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.noMealsRecorded ?? 'Chưa có món ăn nào được ghi nhận',
            style: AppStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.addFirstMeal ?? 'Hãy thêm món ăn đầu tiên của bạn!',
            style: AppStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
