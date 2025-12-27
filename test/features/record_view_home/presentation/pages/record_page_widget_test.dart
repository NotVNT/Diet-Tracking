import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/delete_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/get_food_records_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/save_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/cubit/record_cubit.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/pages/record_page.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

import '../../mocks.mocks.dart';

Widget _wrap(Widget child, {required RecordCubit cubit}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<NotificationProvider>(
        create: (_) => NotificationProvider(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: BlocProvider<RecordCubit>.value(
        value: cubit,
        child: child,
      ),
    ),
  );
}

RecordCubit _buildCubit(MockFoodRecordRepository repository) {
  return RecordCubit(
    SaveFoodRecordUseCase(repository),
    GetFoodRecordsUseCase(repository),
    DeleteFoodRecordUseCase(repository),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Prevent SharedPreferences plugin issues in tests.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('RecordPage widget tests', () {
    late MockFoodRecordRepository repository;

    setUp(() {
      repository = MockFoodRecordRepository();
    });

    testWidgets('renders title and triggers initial load', (tester) async {
      when(repository.getFoodRecords()).thenAnswer((_) async => <FoodRecordEntity>[]);

      final cubit = _buildCubit(repository);

      await tester.pumpWidget(_wrap(const RecordPage(), cubit: cubit));
      await tester.pumpAndSettle();

      // Title in app bar
      expect(find.text('Record Meals'), findsOneWidget);

      verify(repository.getFoodRecords()).called(greaterThanOrEqualTo(1));

      await cubit.close();
    });

    testWidgets('shows empty state when no records', (tester) async {
      when(repository.getFoodRecords()).thenAnswer((_) async => <FoodRecordEntity>[]);

      final cubit = _buildCubit(repository);

      await tester.pumpWidget(_wrap(const RecordPage(), cubit: cubit));
      await tester.pumpAndSettle();

      // From RecordEmptyStateWidget
      expect(find.text('No meals recorded yet'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('shows a record item when records exist and opens details sheet on tap', (tester) async {
      final record = FoodRecordEntity(
        id: '1',
        foodName: 'Apple',
        calories: 95,
        date: DateTime(2025, 1, 1),
        recordType: RecordType.manual,
      );

      when(repository.getFoodRecords()).thenAnswer((_) async => <FoodRecordEntity>[record]);

      final cubit = _buildCubit(repository);

      await tester.pumpWidget(_wrap(const RecordPage(), cubit: cubit));
      await tester.pumpAndSettle();

      // ListTile card key is ValueKey(record.id)
      expect(find.byKey(const ValueKey('1')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('1')));
      await tester.pumpAndSettle();

      // Details sheet shows food name somewhere (RecordDetailsSheet)
      expect(find.textContaining('Apple'), findsWidgets);

      await cubit.close();
    });

    testWidgets('tapping filter button opens FilterSheet', (tester) async {
      when(repository.getFoodRecords()).thenAnswer((_) async => <FoodRecordEntity>[]);
      final cubit = _buildCubit(repository);

      await tester.pumpWidget(_wrap(const RecordPage(), cubit: cubit));
      await tester.pumpAndSettle();

      // FilterButton uses Icons.tune_rounded
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Filter'), findsOneWidget);

      await cubit.close();
    });
  });
}
