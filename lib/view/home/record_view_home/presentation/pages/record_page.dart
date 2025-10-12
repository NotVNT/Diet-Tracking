import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../common/app_colors.dart';
import '../../../../../common/app_styles.dart';
import '../../../../../common/custom_app_bar.dart';
import '../../../../../common/gradient_background.dart';
import '../cubit/record_cubit.dart';
import '../widgets/food_record_list.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  @override
  void initState() {
    super.initState();
    // Load danh sách món ăn khi khởi tạo
    context.read<RecordCubit>().loadFoodRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
