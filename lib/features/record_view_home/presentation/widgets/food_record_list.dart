import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/app_styles.dart';
import '../cubit/record_cubit.dart';
import '../cubit/record_state.dart';

class FoodRecordList extends StatelessWidget {
  const FoodRecordList({Key? key}) : super(key: key);

  /// Formats calories display - shows "~" for chatbot suggestions, exact for manual entries
  String _formatCalories(record) {
    final calories = record.calories.toStringAsFixed(0);
    // If record has nutritionDetails, it came from chatbot suggestion (approximate)
    if (record.nutritionDetails != null && record.nutritionDetails!.trim().isNotEmpty) {
      return '~$calories';
    }
    // Otherwise it's a manual entry (exact)
    return calories;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordCubit, RecordState>(
      builder: (context, state) {
        if (state is RecordLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RecordError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: AppStyles.bodyMedium.copyWith(color: Colors.red[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RecordCubit>().loadFoodRecords();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is RecordListLoaded) {
          final recordsToShow = state.filteredRecords;
          if (recordsToShow.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có món ăn nào được ghi nhận',
                    style: AppStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy thêm món ăn đầu tiên của bạn!',
                    style: AppStyles.bodySmall.copyWith(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recordsToShow.length,
            itemBuilder: (context, index) {
              final record = recordsToShow[index];
              final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

              return Card(
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
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        record.foodName,
                                        style: AppStyles.heading2.copyWith(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${_formatCalories(record)} calories',
                                  style: AppStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if ((record.nutritionDetails ?? '')
                                    .trim()
                                    .isNotEmpty) ...[
                                  Text(
                                    'Thông tin dinh dưỡng',
                                    style: AppStyles.heading2.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    record.nutritionDetails!.trim(),
                                    style: AppStyles.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.restaurant, color: AppColors.primary),
                  ),
                  title: Text(
                    record.foodName,
                    style: AppStyles.heading2.copyWith(fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatCalories(record)} calories',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        dateFormat.format(record.date),
                        style: AppStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: 'Xoá món ăn',
                    icon: Icon(Icons.close_rounded, color: Colors.red[400]),
                    onPressed: () async {
                      // Store the cubit instance before the async gap
                      final cubit = context.read<RecordCubit>();
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text('Xoá món ăn?'),
                            content: Text(
                              'Bạn có chắc muốn xoá "${record.foodName}" khỏi ghi nhận?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(false),
                                child: const Text('Huỷ'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(true),
                                child: const Text(
                                  'Xoá',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true && (record.id != null)) {
                        cubit.deleteFoodRecord(
                          record.id!,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('Đang khởi tạo...'));
      },
    );
  }
}
