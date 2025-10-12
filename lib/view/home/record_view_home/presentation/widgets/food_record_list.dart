import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../common/app_colors.dart';
import '../../../../../common/app_styles.dart';
import '../cubit/record_cubit.dart';
import '../cubit/record_state.dart';

class FoodRecordList extends StatelessWidget {
  const FoodRecordList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordCubit, RecordState>(
      builder: (context, state) {
        if (state is RecordLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (state is RecordError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.red[600],
                  ),
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
          if (state.records.isEmpty) {
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
            itemCount: state.records.length,
            itemBuilder: (context, index) {
              final record = state.records[index];
              final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    record.foodName,
                    style: AppStyles.heading2.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${record.calories.toStringAsFixed(0)} calories',
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
                  trailing: Icon(
                    Icons.check_circle,
                    color: Colors.green[400],
                  ),
                ),
              );
            },
          );
        }
        
        return const Center(
          child: Text('Đang khởi tạo...'),
        );
      },
    );
  }
}
