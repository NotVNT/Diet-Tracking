import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../common/custom_app_bar.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common/app_confirm_dialog.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../../../../record_view_home/presentation/cubit/record_state.dart';
import '../calendar/week_calendar_widget.dart';
import '../cards/calorie_goal_card.dart';
import '../sections/recently_logged_section.dart';
import '../../../../../common/snackbar_helper.dart';
import '../../providers/home_provider.dart';
import '../../../../../config/home_page_config.dart';

class HomeContent extends StatefulWidget {
  final void Function(DateTime, List<FoodRecordEntity>) onViewReport;
  final VoidCallback onEmptyTap;
  final void Function(FoodRecordEntity) onItemTap;

  const HomeContent({
    super.key,
    required this.onViewReport,
    required this.onEmptyTap,
    required this.onItemTap,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final TextEditingController _searchController;
  double? _targetCalories;

  @override
  void initState() {
    super.initState();
    final hp = context.read<HomeProvider>();
    _searchController = TextEditingController(text: hp.searchQuery);
    _searchController.addListener(() {
      final value = _searchController.text;
      final hp = context.read<HomeProvider>();
      if (hp.searchQuery != value) {
        hp.setSearchQuery(value);
      }
    });

    _loadTargetCalories();
  }

  Future<void> _loadTargetCalories() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutrition_plans')
          .doc('active_plan')
          .get(const GetOptions(source: Source.server));
      final data = doc.data();
      if (data != null && data['targetCalories'] != null) {
        setState(() {
          _targetCalories = (data['targetCalories'] as num).toDouble();
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load targetCalories: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: CustomAppBar(title: localizations?.bottomNavHome ?? 'Trang chủ'),
      body: BlocBuilder<RecordCubit, RecordState>(
        buildWhen: (previous, current) {
          if (previous is RecordListLoaded && current is RecordListLoaded) {
            return previous.records.length != current.records.length ||
                previous.records.hashCode != current.records.hashCode;
          }
          return true;
        },
        builder: (context, state) {
          if (state is RecordLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<FoodRecordEntity> foodRecords = [];
          if (state is RecordListLoaded) {
            foodRecords = state.records;
          }

          final String query = homeProvider.searchQuery.trim().toLowerCase();
          final DateTime selectedDate = homeProvider.selectedDate;

          // Filter by selected date and search, keep original sort (newest -> oldest)
          final List<FoodRecordEntity> filteredRecords = foodRecords.where((
            food,
          ) {
            final matchesDate = DateUtils.isSameDay(food.date, selectedDate);
            final matchesSearch =
                query.isEmpty || food.foodName.toLowerCase().contains(query);
            return matchesDate && matchesSearch;
          }).toList();

          // Apply the same display criteria as RecentlyLoggedSection, then take top 5
          final List<FoodRecordEntity> eligibleForDisplay = filteredRecords
              .where((food) {
                final isPhoto =
                    food.recordType == RecordType.food &&
                    food.imagePath != null &&
                    food.imagePath!.isNotEmpty;
                final isBarcode = food.recordType == RecordType.barcode;
                return isPhoto || isBarcode;
              })
              .toList();

          final List<FoodRecordEntity> topFive = eligibleForDisplay.length > 5
              ? eligibleForDisplay.take(5).toList()
              : eligibleForDisplay;

          // Split into photo and barcode lists for the section
          final List<FoodRecordEntity> topPhotoItems = topFive
              .where(
                (food) =>
                    food.recordType == RecordType.food &&
                    food.imagePath != null &&
                    food.imagePath!.isNotEmpty,
              )
              .toList();
          final List<FoodRecordEntity> topBarcodeItems = topFive
              .where((food) => food.recordType == RecordType.barcode)
              .toList();

          final bool hasMoreThanFive = eligibleForDisplay.length > 5;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(responsive.width(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeekCalendarWidget(
                    initialDate: selectedDate,
                    onDateSelected: (d) =>
                        context.read<HomeProvider>().setSelectedDate(d),
                    showMonthYear: true,
                  ),
                  SizedBox(height: responsive.height(16)),
                  CalorieGoalCard(
                    nutritionInfo: NutritionInfo.fromRecordsForDate(
                      records: foodRecords,
                      date: selectedDate,
                      calorieGoal: _targetCalories ?? 0,
                    ),
                    onViewReport: () =>
                        widget.onViewReport(selectedDate, filteredRecords),
                  ),
                  SizedBox(height: responsive.height(16)),
                  RecentlyLoggedSection(
                    photoItems: topPhotoItems,
                    barcodeItems: topBarcodeItems,
                    onViewAllPhotos: () {
                      // Navigate to full list (Record tab) showing newest -> oldest
                      context.read<HomeProvider>().setCurrentIndex(
                        HomePageConfig.recordIndex,
                      );
                    },
                    onItemTap: widget.onItemTap,
                    onDelete: (food) async {
                      final id = food.id;
                      if (id == null) {
                        SnackBarHelper.showError(
                          context,
                          'Không xác định được ID bản ghi để xóa.',
                        );
                        return;
                      }
                      final l10n = AppLocalizations.of(context);
                      final cubit = context.read<RecordCubit>();
                      final confirmed = await showAppConfirmDialog(
                        context,
                        title: l10n?.deleteMealTitle ?? 'Xoá món ăn?',
                        message:
                            l10n?.deleteMealMessage(food.foodName) ??
                            'Bạn có chắc muốn xoá "${food.foodName}" khỏi ghi nhận?',
                        confirmText: l10n?.delete,
                        cancelText: l10n?.cancel,
                        destructive: true,
                        icon: Icons.delete_rounded,
                      );
                      if (confirmed == true) {
                        await cubit.deleteFoodRecord(id);
                        if (!context.mounted) return;
                        SnackBarHelper.showSuccess(
                          context,
                          l10n?.photoDeletedSuccessfully ??
                              'Deleted successfully',
                        );
                      }
                    },
                    onEmptyTap: widget.onEmptyTap,
                    showMoreHint: hasMoreThanFive,
                  ),
                  SizedBox(height: responsive.height(24)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
