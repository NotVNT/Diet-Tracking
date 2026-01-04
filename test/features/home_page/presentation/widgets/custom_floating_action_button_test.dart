import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/home_page/presentation/widgets/navigation/floating_action_button.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _wrap(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    themeMode: themeMode,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
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
          onRecordSelected: () {},
          onScanFoodSelected: () {},
          onReportSelected: () {},
          onChatBotSelected: () {},
          onUploadVideoSelected: () {},
        ),
      ),
    );

    await _openSheet(tester);

    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Scan food'), findsOneWidget);
    expect(find.text('Chat bot'), findsOneWidget);
    expect(find.text('Analyze Video'), findsOneWidget);
  });

  testWidgets('tapping each action triggers the correct callback and dismisses sheet', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var recordCount = 0;
    var scanCount = 0;
    var chatCount = 0;
    var uploadVideoCount = 0;

    await tester.pumpWidget(
      _wrap(
        CustomFloatingActionButton(
          onRecordSelected: () => recordCount++,
          onScanFoodSelected: () => scanCount++,
          onReportSelected: () {},
          onChatBotSelected: () => chatCount++,
          onUploadVideoSelected: () => uploadVideoCount++,
        ),
      ),
    );

    // Upload Video
    await _openSheet(tester);
    await tester.tap(find.text('Analyze Video'));
    await tester.pumpAndSettle();
    expect(uploadVideoCount, 1);
    expect(find.text('Analyze Video'), findsNothing);

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

    // Chat bot
    await _openSheet(tester);
    await tester.tap(find.text('Chat bot'));
    await tester.pumpAndSettle();
    expect(chatCount, 1);
    expect(find.text('Chat bot'), findsNothing);

    expect(recordCount + scanCount + chatCount + uploadVideoCount, 4);
  });

  testWidgets('renders correctly in dark mode', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _wrap(
        CustomFloatingActionButton(
          onRecordSelected: () {},
          onScanFoodSelected: () {},
          onReportSelected: () {},
          onChatBotSelected: () {},
          onUploadVideoSelected: () {},
        ),
        themeMode: ThemeMode.dark,
      ),
    );

    await _openSheet(tester);

    expect(find.text('Record'), findsOneWidget);
    expect(find.text('Scan food'), findsOneWidget);
    expect(find.text('Chat bot'), findsOneWidget);
    expect(find.text('Analyze Video'), findsOneWidget);
  });
}
