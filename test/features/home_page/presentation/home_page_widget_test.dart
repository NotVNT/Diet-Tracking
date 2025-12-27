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

import '../../record_view_home/mocks.mocks.dart';
import '../mocks.mocks.dart';

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
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: BlocProvider<RecordCubit>.value(
        value: recordCubit,
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('HomePage shows bottom nav and switches to Profile tab', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);
    when(homeRepo.updateCurrentIndex(any)).thenAnswer((_) async {});

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );

    // Record cubit dependency
    final recordRepo = MockFoodRecordRepository();
    when(recordRepo.getFoodRecords()).thenAnswer((_) async => [
          FoodRecordEntity(
            id: 'today',
            foodName: 'Test meal',
            calories: 1,
            date: DateTime.now(),
            recordType: RecordType.manual,
          ),
        ]);
    when(recordRepo.deleteFoodRecord(any)).thenAnswer((_) async {});
    when(recordRepo.saveFoodRecord(any)).thenAnswer((_) async {});

    final recordCubit = _buildRecordCubit(recordRepo);

    final page = HomePage(
      pagesBuilder: () => const [
        SizedBox.shrink(),
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

    // Initially Home tab
    expect(find.byKey(const ValueKey('home-tab')), findsOneWidget);

    // Tap Profile icon on bottom nav
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-tab')), findsOneWidget);
    verify(homeRepo.updateCurrentIndex(3)).called(1);

    await recordCubit.close();
  });

  testWidgets('HomePage FAB opens actions and selecting Record changes index', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final homeRepo = MockHomeRepository();
    final homeUsecase = MockGetHomeInfoUseCase();
    final permission = MockPermissionService();
    final notifications = MockLocalNotificationService();

    when(homeUsecase()).thenAnswer((_) async => HomeInfo(currentIndex: 0));
    when(permission.isNotificationPermissionGranted()).thenAnswer((_) async => true);
    when(homeRepo.updateCurrentIndex(any)).thenAnswer((_) async {});

    final homeProvider = HomeProvider(
      getHomeInfoUseCase: homeUsecase,
      repository: homeRepo,
      permissionService: permission,
      notificationService: notifications,
    );

    final recordRepo = MockFoodRecordRepository();
    when(recordRepo.getFoodRecords()).thenAnswer((_) async => [
          FoodRecordEntity(
            id: 'today',
            foodName: 'Test meal',
            calories: 1,
            date: DateTime.now(),
            recordType: RecordType.manual,
          ),
        ]);
    when(recordRepo.deleteFoodRecord(any)).thenAnswer((_) async {});
    when(recordRepo.saveFoodRecord(any)).thenAnswer((_) async {});

    final recordCubit = _buildRecordCubit(recordRepo);

    final page = HomePage(
      pagesBuilder: () => const [
        SizedBox.shrink(),
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

    // Open action sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Select Record
    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('record-tab')), findsOneWidget);
    verify(homeRepo.updateCurrentIndex(1)).called(1);

    await recordCubit.close();
  });
}
