import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/features/home_page/domain/entities/home_info.dart';
import 'package:diet_tracking_project/features/home_page/presentation/pages/home_page.dart';
import 'package:diet_tracking_project/features/home_page/presentation/providers/home_provider.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/delete_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/get_food_records_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/save_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/cubit/record_cubit.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

import '../../../record_view_home/mocks.mocks.dart';
import '../../mocks.mocks.dart';

RecordCubit _buildRecordCubit(MockFoodRecordRepository repository) {
  return RecordCubit(
    SaveFoodRecordUseCase(repository),
    GetFoodRecordsUseCase(repository),
    DeleteFoodRecordUseCase(repository),
  );
}

Widget _wrap({
  required HomeProvider homeProvider,
  required RecordCubit recordCubit,
  required Widget child,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
      ChangeNotifierProvider<NotificationProvider>(
        create: (_) => NotificationProvider(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: BlocProvider<RecordCubit>.value(value: recordCubit, child: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      // Prevent welcome notification from ever showing during tests.
      'notification_welcome_shown_v1': true,
    });
  });

  void configureLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('flow: FAB -> Scan food (not today) shows info snackbar', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );

    // Select a non-today date to trigger the early-return snackbar.
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    homeProvider.setSelectedDate(yesterday);

    final recordRepo = MockFoodRecordRepository();
    when(recordRepo.getFoodRecords()).thenAnswer((_) async => []);
    when(recordRepo.saveFoodRecord(any)).thenAnswer((_) async {});
    when(recordRepo.deleteFoodRecord(any)).thenAnswer((_) async {});
    final recordCubit = _buildRecordCubit(recordRepo);

    final page = HomePage(
      pagesBuilder: () => const [
        SizedBox(key: ValueKey('home-tab')),
        SizedBox(key: ValueKey('record-tab')),
        SizedBox(key: ValueKey('chat-tab')),
        SizedBox(key: ValueKey('profile-tab')),
      ],
      homeContentBuilder: ({required onViewReport, required onEmptyTap, required onItemTap}) {
        return const SizedBox(key: ValueKey('home-tab'));
      },
    );

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: recordCubit, child: page));
    await tester.pumpAndSettle();

    // Open action sheet and select Scan food.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan food'));
    await tester.pumpAndSettle();

    expect(find.text('Bạn chỉ có thể quét món ăn cho ngày hôm nay.'), findsOneWidget);

    await recordCubit.close();
  });

  testWidgets('flow: FAB -> Scan food (today) + camera denied shows warning snackbar', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);
    when(permission.requestCameraPermission()).thenAnswer((_) async => false);

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );
    homeProvider.setSelectedDate(DateTime.now());

    final recordRepo = MockFoodRecordRepository();
    when(recordRepo.getFoodRecords()).thenAnswer((_) async => [
          FoodRecordEntity(
            id: 'today',
            foodName: 'Today',
            calories: 1,
            date: DateTime.now(),
            recordType: RecordType.manual,
          ),
        ]);
    when(recordRepo.saveFoodRecord(any)).thenAnswer((_) async {});
    when(recordRepo.deleteFoodRecord(any)).thenAnswer((_) async {});
    final recordCubit = _buildRecordCubit(recordRepo);

    final page = HomePage(
      pagesBuilder: () => const [
        SizedBox(key: ValueKey('home-tab')),
        SizedBox(key: ValueKey('record-tab')),
        SizedBox(key: ValueKey('chat-tab')),
        SizedBox(key: ValueKey('profile-tab')),
      ],
      homeContentBuilder: ({required onViewReport, required onEmptyTap, required onItemTap}) {
        return const SizedBox(key: ValueKey('home-tab'));
      },
      scanFoodPageBuilder: (context) => const SizedBox(key: ValueKey('scanner-page')),
    );

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: recordCubit, child: page));
    await tester.pumpAndSettle();

    // Open action sheet and select Scan food.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan food'));
    await tester.pumpAndSettle();

    // Should show camera-permission warning (localized en).
    expect(find.text('Please grant camera access to use this feature.'), findsOneWidget);
    // Should not navigate.
    expect(find.byKey(const ValueKey('scanner-page')), findsNothing);

    await recordCubit.close();
  });

  testWidgets('flow: FAB -> Scan food (today) + camera granted navigates and reloads after pop', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);
    when(permission.requestCameraPermission()).thenAnswer((_) async => true);

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );
    homeProvider.setSelectedDate(DateTime.now());

    final recordRepo = MockFoodRecordRepository();
    // Return a "today" record so the guided FAB arrow stays hidden.
    when(recordRepo.getFoodRecords()).thenAnswer((_) async => [
          FoodRecordEntity(
            id: 'today',
            foodName: 'Today',
            calories: 1,
            date: DateTime.now(),
            recordType: RecordType.manual,
          ),
        ]);
    when(recordRepo.saveFoodRecord(any)).thenAnswer((_) async {});
    when(recordRepo.deleteFoodRecord(any)).thenAnswer((_) async {});
    final recordCubit = _buildRecordCubit(recordRepo);

    final page = HomePage(
      pagesBuilder: () => const [
        SizedBox(key: ValueKey('home-tab')),
        SizedBox(key: ValueKey('record-tab')),
        SizedBox(key: ValueKey('chat-tab')),
        SizedBox(key: ValueKey('profile-tab')),
      ],
      homeContentBuilder: ({required onViewReport, required onEmptyTap, required onItemTap}) {
        return const SizedBox(key: ValueKey('home-tab'));
      },
      scanFoodPageBuilder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Scanner')),
          body: const SizedBox(key: ValueKey('scanner-page')),
        );
      },
    );

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: recordCubit, child: page));
    await tester.pumpAndSettle();

    // Open action sheet and select Scan food.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan food'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('scanner-page')), findsOneWidget);

    // Pop scanner page.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Should reload records again after returning.
    verify(recordRepo.getFoodRecords()).called(greaterThan(1));

    await recordCubit.close();
  });

  testWidgets('flow: FAB -> Report navigates to NutritionSummaryPage', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );

    // Not-today prevents the guided arrow from appearing.
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    homeProvider.setSelectedDate(yesterday);

    final recordRepo = MockFoodRecordRepository();
    when(recordRepo.getFoodRecords()).thenAnswer((_) async => []);
    when(recordRepo.saveFoodRecord(any)).thenAnswer((_) async {});
    when(recordRepo.deleteFoodRecord(any)).thenAnswer((_) async {});
    final recordCubit = _buildRecordCubit(recordRepo);

    final page = HomePage(
      pagesBuilder: () => const [
        SizedBox(key: ValueKey('home-tab')),
        SizedBox(key: ValueKey('record-tab')),
        SizedBox(key: ValueKey('chat-tab')),
        SizedBox(key: ValueKey('profile-tab')),
      ],
      homeContentBuilder: ({required onViewReport, required onEmptyTap, required onItemTap}) {
        return const SizedBox(key: ValueKey('home-tab'));
      },
    );

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: recordCubit, child: page));
    await tester.pumpAndSettle();

    // Open action sheet and select Report.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();

    expect(find.text('Thống kê dinh dưỡng'), findsOneWidget);
    expect(find.text('Tuần này'), findsOneWidget);
    expect(find.text('Tháng này'), findsOneWidget);

    await recordCubit.close();
  });
}
