import 'package:diet_tracking_project/widget/daily_activities/activity_option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ActivityOptionCard displays title, description and icon',
      (WidgetTester tester) async {
    const title = 'Test Title';
    const description = 'Test Description';
    const icon = Icons.ac_unit;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityOptionCard(
            title: title,
            description: description,
            icon: icon,
            isSelected: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('$title $description', findRichText: true), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);
  });

  testWidgets('ActivityOptionCard shows checkmark when selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityOptionCard(
            title: 'Title',
            description: 'Description',
            icon: Icons.abc,
            isSelected: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('ActivityOptionCard does not show checkmark when not selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityOptionCard(
            title: 'Title',
            description: 'Description',
            icon: Icons.abc,
            isSelected: false,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('ActivityOptionCard calls onTap when tapped',
      (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityOptionCard(
            title: 'Title',
            description: 'Description',
            icon: Icons.abc,
            isSelected: false,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ActivityOptionCard));
    expect(tapped, isTrue);
  });
}
