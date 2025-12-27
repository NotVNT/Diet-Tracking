import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/config/home_page_config.dart';
import 'package:diet_tracking_project/features/home_page/domain/entities/home_info.dart';
import 'package:diet_tracking_project/features/home_page/presentation/providers/home_provider.dart';
import 'package:diet_tracking_project/features/home_page/presentation/widgets/layout/home_content.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/delete_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/get_food_records_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/save_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/cubit/record_cubit.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/cubit/record_state.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

import '../../record_view_home/mocks.mocks.dart';
import '../mocks.mocks.dart';

class TestableRecordCubit extends RecordCubit {
  TestableRecordCubit(
    super.saveUseCase,
    super.getUseCase,
    super.deleteUseCase,
  );

  void setTestState(RecordState state) => emit(state);
}

Widget _wrap({required HomeProvider homeProvider, required RecordCubit recordCubit}) {
  return MultiProvider(
    providers: [ChangeNotifierProvider<HomeProvider>.value(value: homeProvider)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationProvider>(
            create: (_) => NotificationProvider(),
          ),
        ],
        child: BlocProvider<RecordCubit>.value(
          value: recordCubit,
          child: HomeContent(
            onViewReport: (_, __) {},
            onEmptyTap: () {},
            onItemTap: (_) {},
          ),
        ),
      ),
    ),
  );
}

FoodRecordEntity _barcode({
  required String id,
  required String name,
  required DateTime date,
}) {
  return FoodRecordEntity(
    id: id,
    foodName: name,
    calories: 123,
    date: date,
    recordType: RecordType.barcode,
    barcode: '123456',
  );
}

FoodRecordEntity _photo({
  required String id,
  required String name,
  required DateTime date,
}) {
  return FoodRecordEntity(
    id: id,
    foodName: name,
    calories: 456,
    date: date,
    recordType: RecordType.food,
    imagePath: 'invalid-url',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  void configureLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('HomeContent shows loading indicator for RecordLoading state', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    // Deny notification permission so provider never calls notificationService.
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => false);
    when(permission.requestNotificationPermission()).thenAnswer((_) async => false);
    when(homeRepo.updateCurrentIndex(any)).thenAnswer((_) async {});

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );
    homeProvider.setSelectedDate(DateTime(2025, 12, 28));

    final recordRepo = MockFoodRecordRepository();
    final cubit = TestableRecordCubit(
      SaveFoodRecordUseCase(recordRepo),
      GetFoodRecordsUseCase(recordRepo),
      DeleteFoodRecordUseCase(recordRepo),
    )..setTestState(RecordLoading());

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: cubit));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await cubit.close();
  });

  testWidgets('HomeContent shows empty state when no eligible records match', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => false);
    when(permission.requestNotificationPermission()).thenAnswer((_) async => false);
    when(homeRepo.updateCurrentIndex(any)).thenAnswer((_) async {});

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );
    final selected = DateTime(2025, 12, 28, 9, 0);
    homeProvider.setSelectedDate(selected);

    final recordRepo = MockFoodRecordRepository();
    final cubit = TestableRecordCubit(
      SaveFoodRecordUseCase(recordRepo),
      GetFoodRecordsUseCase(recordRepo),
      DeleteFoodRecordUseCase(recordRepo),
    )
      ..setTestState(
        RecordListLoaded(
          [
            FoodRecordEntity(
              id: 'manual-1',
              foodName: 'Manual item',
              calories: 10,
              date: selected,
              recordType: RecordType.manual,
            ),
          ],
        ),
      );

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text("You haven't uploaded any food"), findsOneWidget);

    await cubit.close();
  });

  testWidgets('HomeContent filters records by search query (case-insensitive)', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => false);
    when(permission.requestNotificationPermission()).thenAnswer((_) async => false);
    when(homeRepo.updateCurrentIndex(any)).thenAnswer((_) async {});

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );
    final selected = DateTime(2025, 12, 28, 9, 0);
    homeProvider.setSelectedDate(selected);
    homeProvider.setSearchQuery('app');

    final recordRepo = MockFoodRecordRepository();
    final cubit = TestableRecordCubit(
      SaveFoodRecordUseCase(recordRepo),
      GetFoodRecordsUseCase(recordRepo),
      DeleteFoodRecordUseCase(recordRepo),
    )
      ..setTestState(
        RecordListLoaded([
          _barcode(id: 'a', name: 'Apple', date: selected),
          _barcode(id: 'b', name: 'Banana', date: selected),
        ]),
      );

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);

    await cubit.close();
  });

  testWidgets('HomeContent filters records by selected date (same day)', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => false);
    when(permission.requestNotificationPermission()).thenAnswer((_) async => false);
    when(homeRepo.updateCurrentIndex(any)).thenAnswer((_) async {});

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );
    final day = DateTime(2025, 12, 28, 9, 0);
    final otherDay = DateTime(2025, 12, 27, 9, 0);
    homeProvider.setSelectedDate(day);

    final recordRepo = MockFoodRecordRepository();
    final cubit = TestableRecordCubit(
      SaveFoodRecordUseCase(recordRepo),
      GetFoodRecordsUseCase(recordRepo),
      DeleteFoodRecordUseCase(recordRepo),
    )
      ..setTestState(
        RecordListLoaded([
          _barcode(id: 'today', name: 'Today item', date: day),
          _barcode(id: 'yday', name: 'Yesterday item', date: otherDay),
        ]),
      );

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text('Today item'), findsOneWidget);
    expect(find.text('Yesterday item'), findsNothing);

    await cubit.close();
  });

  testWidgets('HomeContent tapping View all switches to Record tab index', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => false);
    when(permission.requestNotificationPermission()).thenAnswer((_) async => false);
    when(homeRepo.updateCurrentIndex(any)).thenAnswer((_) async {});

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );
    final selected = DateTime(2025, 12, 28, 9, 0);
    homeProvider.setSelectedDate(selected);

    final recordRepo = MockFoodRecordRepository();
    final cubit = TestableRecordCubit(
      SaveFoodRecordUseCase(recordRepo),
      GetFoodRecordsUseCase(recordRepo),
      DeleteFoodRecordUseCase(recordRepo),
    )
      ..setTestState(RecordListLoaded([
        _barcode(id: 'a', name: 'Any', date: selected),
      ]));

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: cubit));
    await tester.pumpAndSettle();

    expect(homeProvider.currentIndex, 0);
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();

    expect(homeProvider.currentIndex, HomePageConfig.recordIndex);
    verify(homeRepo.updateCurrentIndex(HomePageConfig.recordIndex)).called(1);

    await cubit.close();
  });

  testWidgets('HomeContent delete flow calls RecordCubit.deleteFoodRecord and shows success snackbar', (tester) async {
    configureLargeViewport(tester);

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => false);
    when(permission.requestNotificationPermission()).thenAnswer((_) async => false);
    when(homeRepo.updateCurrentIndex(any)).thenAnswer((_) async {});

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );
    final selected = DateTime(2025, 12, 28, 9, 0);
    homeProvider.setSelectedDate(selected);

    final recordRepo = MockFoodRecordRepository();
    final save = SaveFoodRecordUseCase(recordRepo);
    final get = GetFoodRecordsUseCase(recordRepo);
    final del = DeleteFoodRecordUseCase(recordRepo);

    final record = _photo(id: 'p1', name: 'Photo meal', date: selected);
    when(recordRepo.getFoodRecords()).thenAnswer((_) async => [record]);
    when(recordRepo.deleteFoodRecord(any)).thenAnswer((_) async {});
    when(recordRepo.saveFoodRecord(any)).thenAnswer((_) async {});

    final cubit = TestableRecordCubit(save, get, del);

    await tester.pumpWidget(_wrap(homeProvider: homeProvider, recordCubit: cubit));

    // Load records to seed cubit's internal _allRecords.
    await cubit.loadFoodRecords();
    await tester.pumpAndSettle();

    expect(find.text('Photo meal'), findsOneWidget);

    // Open More options menu via tooltip.
    await tester.tap(find.byTooltip('More options').first);
    await tester.pumpAndSettle();

    // Tap Delete in bottom sheet.
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Confirm dialog.
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(recordRepo.deleteFoodRecord('p1')).called(1);
    expect(find.text('Deleted successfully'), findsOneWidget);

    await cubit.close();
  });
}
