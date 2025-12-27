import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/home_page/presentation/widgets/navigation/floating_action_button.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: child,
      bottomNavigationBar: const SizedBox(height: 56),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens action sheet and shows all actions', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _wrap(
        CustomFloatingActionButton(
          onAddFoodSelected: () {},
          onRecordSelected: () {},
          onScanFoodSelected: () {},
          onReportSelected: () {},
          onChatBotSelected: () {},
        ),
      ),
    );

    await _openSheet(tester);

    expect(find.text('Add Food'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Scan food'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Chat bot'), findsOneWidget);
  });

  testWidgets('tapping each action triggers the correct callback and dismisses sheet', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var addFoodCount = 0;
    var recordCount = 0;
    var scanCount = 0;
    var reportCount = 0;
    var chatCount = 0;

    await tester.pumpWidget(
      _wrap(
        CustomFloatingActionButton(
          onAddFoodSelected: () => addFoodCount++,
          onRecordSelected: () => recordCount++,
          onScanFoodSelected: () => scanCount++,
          onReportSelected: () => reportCount++,
          onChatBotSelected: () => chatCount++,
        ),
      ),
    );

    // Add Food
    await _openSheet(tester);
    await tester.tap(find.text('Add Food'));
    await tester.pumpAndSettle();
    expect(addFoodCount, 1);
    expect(find.text('Add Food'), findsNothing);

    // Record
    await _openSheet(tester);
    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();
    expect(recordCount, 1);
    expect(find.text('Record'), findsNothing);

    // Scan food
    await _openSheet(tester);
    await tester.tap(find.text('Scan food'));
    await tester.pumpAndSettle();
    expect(scanCount, 1);
    expect(find.text('Scan food'), findsNothing);

    // Report
    await _openSheet(tester);
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(reportCount, 1);
    expect(find.text('Report'), findsNothing);

    // Chat bot
    await _openSheet(tester);
    await tester.tap(find.text('Chat bot'));
    await tester.pumpAndSettle();
    expect(chatCount, 1);
    expect(find.text('Chat bot'), findsNothing);

    expect(addFoodCount + recordCount + scanCount + reportCount + chatCount, 5);
  });
}
