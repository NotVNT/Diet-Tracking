import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/app_styles.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../common/gradient_background.dart';
import '../../di/record_di.dart';
import '../cubit/record_cubit.dart';
import '../widgets/food_record_list.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecordCubit>(
      create: (context) => RecordDI.getRecordCubit()..loadFoodRecords(),
      child: Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Ghi nhận món ăn'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Danh sách món ăn đã ghi nhận
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Món ăn đã ghi nhận',
                                style: AppStyles.heading2.copyWith(
                                  fontSize: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const FoodRecordList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
