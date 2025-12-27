import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/record_view_home/presentation/widgets/filter_sheet.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _wrapWithSheetLauncher({required VoidCallback onOpen}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: onOpen,
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(
  WidgetTester tester, {
  String? initialCalorieRange,
  DateTimeRange? initialDateRange,
  required void Function(String? calorieRange, DateTimeRange? dateRange) onApply,
  VoidCallback? onClear,
}) async {
  await tester.pumpWidget(
    _wrapWithSheetLauncher(
      onOpen: () {
        showModalBottomSheet<void>(
          context: tester.element(find.text('Open')),
          isScrollControlled: true,
          builder: (_) {
            return FilterSheet(
              calorieRange: initialCalorieRange,
              dateRange: initialDateRange,
              onApply: onApply,
              onClear: onClear,
            );
          },
        );
      },
    ),
  );

  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FilterSheet widget', () {
    testWidgets('tapping Apply calls onApply with initial values and closes', (tester) async {
      String? appliedCalorie;
      DateTimeRange? appliedRange;

      final initialRange = DateTimeRange(
        start: DateTime(2025, 12, 1),
        end: DateTime(2025, 12, 7),
      );

      await _openSheet(
        tester,
        initialCalorieRange: '250-500',
        initialDateRange: initialRange,
        onApply: (c, r) {
          appliedCalorie = c;
          appliedRange = r;
        },
      );

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(appliedCalorie, '250-500');
      expect(appliedRange?.start, initialRange.start);
      expect(appliedRange?.end, initialRange.end);

      // Sheet closed
      expect(find.text('Filter'), findsNothing);
    });

    testWidgets('Reset calls onClear and Apply afterwards sends null filters', (tester) async {
      int clearCalls = 0;
      String? appliedCalorie;
      DateTimeRange? appliedRange;

      await _openSheet(
        tester,
        initialCalorieRange: '250-500',
        initialDateRange: DateTimeRange(
          start: DateTime(2025, 12, 1),
          end: DateTime(2025, 12, 7),
        ),
        onApply: (c, r) {
          appliedCalorie = c;
          appliedRange = r;
        },
        onClear: () => clearCalls++,
      );

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(clearCalls, 1);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(appliedCalorie, isNull);
      expect(appliedRange, isNull);
    });

    testWidgets('Select calorie chip and Today then Apply returns non-null range', (tester) async {
      String? appliedCalorie;
      DateTimeRange? appliedRange;

      await _openSheet(
        tester,
        onApply: (c, r) {
          appliedCalorie = c;
          appliedRange = r;
        },
      );

      // Select calorie chip
      await tester.tap(find.text('0-250 Cal'));
      await tester.pump();

      // Select today
      await tester.tap(find.text('Today'));
      await tester.pump();

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(appliedCalorie, '0-250');
      expect(appliedRange, isNotNull);

      final now = DateTime.now();
      expect(appliedRange!.start.year, now.year);
      expect(appliedRange!.start.month, now.month);
      expect(appliedRange!.start.day, now.day);
      expect(appliedRange!.start.hour, 0);
      expect(appliedRange!.start.minute, 0);

      expect(appliedRange!.end.year, now.year);
      expect(appliedRange!.end.month, now.month);
      expect(appliedRange!.end.day, now.day);
      expect(appliedRange!.end.hour, 23);
      expect(appliedRange!.end.minute, 59);
    });

    testWidgets('close icon pops without calling onApply', (tester) async {
      int applyCalls = 0;

      await _openSheet(
        tester,
        onApply: (_, __) => applyCalls++,
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(applyCalls, 0);
      expect(find.text('Filter'), findsNothing);
    });
  });
}
