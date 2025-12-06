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
import '../widgets/filter_button.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/search_bar.dart' as record_widgets;

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Ensure records are loaded on first frame
    final cubit = context.read<RecordCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cubit.state is RecordInitial) {
        cubit.loadFoodRecords();
      }
    });

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations?.recordedMealsTitle ?? 'Món ăn đã ghi nhận',
                      style: AppStyles.heading2.copyWith(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search + Filter button
                    BlocBuilder<RecordCubit, RecordState>(
                      buildWhen: (prev, curr) => true,
                      builder: (context, state) {
                        final cubit = context.read<RecordCubit>();
                        return record_widgets.SearchBar(
                          onSearchChanged: (query) =>
                              context.read<RecordCubit>().setSearchQuery(query),
                          trailing: FilterButton(
                            highlighted: cubit.hasActiveFilters,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: false,
                                useSafeArea: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                builder: (_) => DraggableScrollableSheet(
                                  initialChildSize: 0.5,
                                  minChildSize: 0.3,
                                  maxChildSize: 0.9,
                                  expand: false,
                                  builder: (context, controller) => FilterSheet(
                                    scrollController: controller,
                                    calorieRange: cubit.calorieRange,
                                    dateRange: cubit.dateRange,
                                    onApply: (calRange, dateRange) {
                                      final c = context.read<RecordCubit>();
                                      c.setFilters(calorieRange: calRange, dateRange: dateRange);
                                    },
                                    onClear: () {
                                      final c = context.read<RecordCubit>();
                                      c.clearFilters();
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: FoodRecordList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
