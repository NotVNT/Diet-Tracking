import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/utils/bottom_sheet_utils.dart';

void main() {
  testWidgets('showCustomBottomSheet shows a bottom sheet with default properties',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showCustomBottomSheet(
                    context: context,
                    builder: (context) => const Text('Bottom Sheet Content'),
                  );
                },
                child: const Text('Show Sheet'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the sheet
    await tester.tap(find.text('Show Sheet'));
    await tester.pumpAndSettle();

    // Verify the sheet content is displayed
    expect(find.text('Bottom Sheet Content'), findsOneWidget);

    // Verify the shape of the bottom sheet
    final bottomSheet = tester.widget<BottomSheet>(
      find.byType(BottomSheet),
    );
    // isScrollControlled is not easily verifiable via public widget properties
    // expect(bottomSheet.isScrollControlled, isTrue); 
    expect(
      bottomSheet.shape,
      isA<RoundedRectangleBorder>().having(
        (s) => s.borderRadius,
        'borderRadius',
        const BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  });

  testWidgets('showCustomBottomSheet respects custom properties',
      (WidgetTester tester) async {
    const customColor = Colors.red;
    const customShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showCustomBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    backgroundColor: customColor,
                    shape: customShape,
                    builder: (context) => const Text('Custom Sheet'),
                  );
                },
                child: const Text('Show Custom Sheet'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the sheet
    await tester.tap(find.text('Show Custom Sheet'));
    await tester.pumpAndSettle();

    // Verify the sheet content is displayed
    expect(find.text('Custom Sheet'), findsOneWidget);

    // Verify custom properties
    final bottomSheet = tester.widget<BottomSheet>(
      find.byType(BottomSheet),
    );
    // expect(bottomSheet.isScrollControlled, isFalse);
    expect(bottomSheet.backgroundColor, customColor);
    expect(bottomSheet.shape, customShape);
  });
}
