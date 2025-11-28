import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/app_styles.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../common/gradient_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../common/snackbar_helper.dart';
import '../cubit/record_state.dart';

import '../cubit/record_cubit.dart';
import '../widgets/food_record_list.dart';
import '../widgets/calorie_filter.dart';


class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: BlocListener<RecordCubit, RecordState>(
        listener: (context, state) {
          if (state is RecordSuccess) {
            SnackBarHelper.showSuccess(context, state.message);
          } else if (state is RecordError) {
            SnackBarHelper.showError(context, state.message);
          }
        },
        child: GradientBackground(
        child: Column(
          children: [
            CustomAppBar(
              title: localizations?.recordPageTitle ?? 'Ghi nhận món ăn',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Danh sách món ăn đã ghi nhận (without card wrapper)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations?.recordedMealsTitle ?? 'Món ăn đã ghi nhận',
                            style: AppStyles.heading2.copyWith(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CalorieFilter(
                            onFilterChanged: (filter) {
                              context.read<RecordCubit>().filterRecordsByCalories(filter);
                            },
                          ),
                          const SizedBox(height: 16),
                          const FoodRecordList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),), // Close GradientBackground and BlocListener
    );
  }
}
