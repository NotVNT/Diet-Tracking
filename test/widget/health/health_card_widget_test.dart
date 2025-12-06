import 'package:diet_tracking_project/widget/health/health_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _buildTestWidget({
    List<String> items = const [],
    void Function(int)? onRemoveItem,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HealthCardWidget(
          index: 1,
          title: 'Test Title',
          description: 'Test Description',
          input: const TextField(),
          trailingButton: ElevatedButton(onPressed: () {}, child: const Text('Add')),
          emptyIcon: Icons.info,
          emptyText: 'No items',
          items: items,
          onRemoveItem: onRemoveItem,
        ),
      ),
    );
  }

  testWidgets('Renders basic info and input widgets', (tester) async {
    await tester.pumpWidget(_buildTestWidget());

    expect(find.text('1'), findsOneWidget);
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Shows empty state when items list is empty', (tester) async {
    await tester.pumpWidget(_buildTestWidget());

    expect(find.byIcon(Icons.info), findsOneWidget);
    expect(find.text('No items'), findsOneWidget);
  });

  testWidgets('Displays chips when items are provided', (tester) async {
    await tester.pumpWidget(_buildTestWidget(items: ['Apple', 'Banana']));

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(2));
  });

  testWidgets('Calls onRemoveItem when a chip is deleted', (tester) async {
    int? removedIndex;
    await tester.pumpWidget(_buildTestWidget(
      items: ['Apple', 'Banana'],
      onRemoveItem: (index) => removedIndex = index,
    ));

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(removedIndex, 0);
  });
}
