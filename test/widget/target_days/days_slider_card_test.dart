import 'package:diet_tracking_project/widget/target_days/days_slider_card.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('vi'),
    home: Scaffold(
      body: Material(
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    // Avoid network calls for font fetching in widget tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('DaysSliderCard', () {
    testWidgets('renders selected days and weeks text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DaysSliderCard(
            selectedDays: 14,
            onDaysChanged: (_) {},
          ),
        ),
      );

      expect(find.text('14 ngày'), findsOneWidget);
      expect(find.text('≈ 2.0 tuần'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('invokes onDaysChanged when slider changes', (tester) async {
      int? changedTo;

      await tester.pumpWidget(
        _wrap(
          DaysSliderCard(
            selectedDays: 14,
            onDaysChanged: (value) => changedTo = value,
            minDays: 7,
            maxDays: 365,
          ),
        ),
      );

      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpAndSettle();

      expect(changedTo, isNotNull);
      expect(changedTo, inInclusiveRange(7, 365));
    });
  });
}
