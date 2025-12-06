import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../common/app_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../common/app_confirm_dialog.dart';
import '../../../../common/snackbar_helper.dart';
import '../../domain/entities/food_record_entity.dart';
import '../../../home_page/presentation/widgets/food_scanned/food_scanned_info.dart';
import '../cubit/record_cubit.dart';
import '../cubit/record_state.dart';

import 'record_details_sheet.dart';
import 'record_tag.dart';


class FoodRecordList extends StatelessWidget {
  const FoodRecordList({super.key});

  Future<void> _confirmAndDelete(BuildContext context, FoodRecordEntity record) async {
    final cubit = context.read<RecordCubit>();
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n?.deleteMealTitle ?? 'Xoá món ăn?',
      message: l10n?.deleteMealMessage(record.foodName) ??
          'Bạn có chắc muốn xoá "${record.foodName}" khỏi ghi nhận?',
      confirmText: l10n?.delete,
      cancelText: l10n?.cancel,
      destructive: true,
      icon: Icons.delete_rounded,
    );

    if (confirmed == true && record.id != null) {
      try {
        await cubit.deleteFoodRecord(record.id!);
        if (context.mounted) {
          SnackBarHelper.showSuccess(
            context,
            l10n?.mealDeletedSuccessfully ?? 'Meal deleted successfully',
          );
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showError(
            context,
            l10n?.deleteMealFailed ?? 'Failed to delete meal',
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocBuilder<RecordCubit, RecordState>(
      builder: (context, state) {
        if (state is RecordLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RecordError) {
          return RecordErrorWidget(
            message: state.message,
            onRetry: () => context.read<RecordCubit>().loadFoodRecords(),
          );
        }

        if (state is RecordListLoaded) {
          final recordsToShow = state.filteredRecords;
          if (recordsToShow.isEmpty) {
            return const RecordEmptyStateWidget();
          }

          final dateFormat = DateFormat('dd/MM/yyyy');

          return ListView.builder(
            itemCount: recordsToShow.length,
            itemBuilder: (context, index) {
              final record = recordsToShow[index];

              return Card(
                key: ValueKey(record.id ?? '${record.foodName}-${record.date.millisecondsSinceEpoch}'),
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (ctx) {
                        return RecordDetailsSheet(record: record);
                      },
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.restaurant,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: FoodScannedInfo(
                    record: record,
                    showTime: false,
                    emphasizeCalories: true,
                    approxForBotSuggestion: true,
                    caloriesSuffix: localizations?.calories ?? 'calories',
                    showMacros: false,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateFormat.format(record.date),
                              style: AppStyles.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            fit: FlexFit.loose,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: RecordTag(record: record),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: localizations?.deleteMealTooltip ?? 'Xoá món ăn',
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _confirmAndDelete(context, record),
                  ),
                ),
              );
            },
          );
        }

        return Center(child: Text(localizations?.initializing ?? 'Đang khởi tạo...'));
      },
    );
  }
}
