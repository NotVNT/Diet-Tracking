import 'package:diet_tracking_project/widget/health/add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AddButton displays icon and responds to taps', (tester) async {
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddButton(
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byType(AddButton));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
