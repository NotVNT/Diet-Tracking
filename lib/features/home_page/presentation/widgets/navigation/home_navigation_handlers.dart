import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../common/snackbar_helper.dart';
import '../../../../../config/home_page_config.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../food_scanner/presentation/pages/food_scanner_page.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../../../../record_view_home/presentation/cubit/record_state.dart';
import '../../pages/nutrition_summary_page.dart';
import '../../providers/home_provider.dart';


class HomeNavigationHandlers {
  static void navigateToRecord(
    BuildContext context, {
    bool popCurrentRoute = false,
  }) {
    context.read<HomeProvider>().setCurrentIndex(HomePageConfig.recordIndex);
    if (popCurrentRoute && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static void navigateToChatBot(
    BuildContext context, {
    bool popCurrentRoute = false,
  }) {
    context.read<HomeProvider>().setCurrentIndex(HomePageConfig.chatBotIndex);
    if (popCurrentRoute && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static Future<void> navigateToScanFood(
    BuildContext context, {
    bool replaceCurrentRoute = false,
  }) async {
    final homeProvider = context.read<HomeProvider>();

    // Only allow scanning for today (same as HomePage).
    final bool isTodaySelected = DateUtils.isSameDay(
      homeProvider.selectedDate,
      DateTime.now(),
    );
    if (!isTodaySelected) {
      SnackBarHelper.showInfo(
        context,
        'Bạn chỉ có thể quét món ăn cho ngày hôm nay.',
      );
      return;
    }

    final hasPermission = await homeProvider.requestCameraPermission();
    if (!hasPermission) {
      if (!context.mounted) return;
      final localizations = AppLocalizations.of(context);
      SnackBarHelper.showWarning(
        context,
        localizations?.permissionCameraRequired ??
            'Vui lòng cấp quyền truy cập máy ảnh để sử dụng tính năng này.',
      );
      return;
    }

    if (!context.mounted) return;

    final route = MaterialPageRoute<void>(
      builder: (_) => const FoodScannerPage(),
    );

    if (replaceCurrentRoute) {
      await Navigator.of(context).pushReplacement(route);
    } else {
      await Navigator.of(context).push(route);
    }

    if (!context.mounted) return;
    context.read<RecordCubit>().loadFoodRecords();
  }

  static void navigateToReport(BuildContext context) {
    final selectedDate = context.read<HomeProvider>().selectedDate;

    final state = context.read<RecordCubit>().state;
    List<FoodRecordEntity> allRecords = [];
    if (state is RecordListLoaded) {
      allRecords = state.records;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NutritionSummaryPage(
          selectedDate: selectedDate,
          allRecords: allRecords,
        ),
      ),
    );
  }

  static void onBottomNavTap(
    BuildContext context,
    int index, {
    bool popCurrentRoute = false,
  }) {
    if (!HomePageConfig.isValidIndex(index)) return;

    if (index == HomePageConfig.recordIndex) {
      context.read<RecordCubit>().loadFoodRecords();
    }

    context.read<HomeProvider>().setCurrentIndex(index);

    if (popCurrentRoute && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
