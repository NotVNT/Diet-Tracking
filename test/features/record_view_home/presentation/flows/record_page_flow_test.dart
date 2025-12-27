import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
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
  // Important: BlocProvider must wrap MaterialApp so that new routes
  // (e.g., showModalBottomSheet/showDialog) can still access RecordCubit.
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<NotificationProvider>(
        create: (_) => NotificationProvider(),
      ),
    ],
    child: BlocProvider<RecordCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
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
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('RecordPage flow: search → filter → open details → delete', (tester) async {
    final repository = MockFoodRecordRepository();

    final records = <FoodRecordEntity>[
      FoodRecordEntity(
        id: '1',
        foodName: 'Apple',
        calories: 95,
        date: DateTime(2025, 12, 27, 8, 0, 0),
        recordType: RecordType.manual,
      ),
      FoodRecordEntity(
        id: '2',
        foodName: 'Burger',
        calories: 600,
        date: DateTime(2025, 12, 26, 8, 0, 0),
        recordType: RecordType.manual,
      ),
    ];

    when(repository.getFoodRecords()).thenAnswer((_) async => records);
    when(repository.deleteFoodRecord(any)).thenAnswer((_) async {});

    final cubit = _buildCubit(repository);

    await tester.pumpWidget(_wrap(const RecordPage(), cubit: cubit));
    await tester.pumpAndSettle();

    // initial load shows both records
    expect(find.byKey(const ValueKey('1')), findsOneWidget);
    expect(find.byKey(const ValueKey('2')), findsOneWidget);

    // Search (debounced)
    await tester.enterText(find.byType(TextField), '  app  ');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('1')), findsOneWidget);
    expect(find.byKey(const ValueKey('2')), findsNothing);

    // Clear search (avoid ambiguous close icons by clearing text)
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('1')), findsOneWidget);
    expect(find.byKey(const ValueKey('2')), findsOneWidget);

    // Filter calories
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filter'), findsOneWidget);

    // The bottom sheet is shown inside a DraggableScrollableSheet.
    // In the widget test viewport (800x600), parts of the content can be off-screen.
    // Expand/scroll it before interacting.
    await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('0-250 Cal'));
    await tester.tap(find.text('0-250 Cal'));
    await tester.pump();

    await tester.ensureVisible(find.text('Apply'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('1')), findsOneWidget);
    expect(find.byKey(const ValueKey('2')), findsNothing);

    // Open details sheet
    await tester.tap(find.byKey(const ValueKey('1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Apple'), findsWidgets);

    // Close details sheet (showModalBottomSheet) by tapping the modal barrier.
    await tester.tap(find.byType(ModalBarrier).first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Delete the remaining visible record (list trailing close icon)
    final deleteButton = find.descendant(
      of: find.byKey(const ValueKey('1')),
      matching: find.byIcon(Icons.close_rounded),
    );
    await tester.tap(deleteButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Confirm dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(repository.deleteFoodRecord('1')).called(1);

    // With calorie filter still active, no records should match
    expect(find.text('No meals recorded yet'), findsOneWidget);

    await cubit.close();
  });
}
