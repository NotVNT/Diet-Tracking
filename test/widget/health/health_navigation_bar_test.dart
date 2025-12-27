import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/widget/health/health_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('HealthNavigationBar', () {
    testWidgets('calls onBack and onNext when tapped', (tester) async {
      var backCount = 0;
      var nextCount = 0;

      await tester.pumpWidget(
        _wrap(
          HealthNavigationBar(
            onBack: () => backCount++,
            onNext: () => nextCount++,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      expect(backCount, 1);

      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(nextCount, 1);
    });
  });
}
