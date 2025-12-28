import 'package:diet_tracking_project/widget/target_days/warning_card.dart';
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
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('WarningCard', () {
    testWidgets('renders warning title, message, icon and recommended days', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const WarningCard(
            warningMessage: 'Test warning message',
            recommendedDays: 30,
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Cảnh báo'), findsOneWidget);
      expect(find.text('Test warning message'), findsOneWidget);
      expect(find.text('Khuyến nghị: 30 ngày'), findsOneWidget);
    });
  });
}
