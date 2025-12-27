import 'package:diet_tracking_project/widget/health/health_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthBackground', () {
    testWidgets('renders decorative icons and child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthBackground(
              child: Text('CONTENT'),
            ),
          ),
        ),
      );

      expect(find.text('CONTENT'), findsOneWidget);
      expect(find.byIcon(Icons.local_pizza), findsOneWidget);
      expect(find.byIcon(Icons.icecream), findsOneWidget);
      expect(find.byIcon(Icons.bakery_dining), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsOneWidget);
    });
  });
}
