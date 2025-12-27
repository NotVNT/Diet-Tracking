import 'package:diet_tracking_project/widget/health/health_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('HealthHeader', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HealthHeader(
              title: 'TITLE',
              subtitle: 'SUBTITLE',
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.text('TITLE'), findsOneWidget);
      expect(find.text('SUBTITLE'), findsOneWidget);
    });
  });
}
