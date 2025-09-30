import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/widget/weight/bmi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapWithApp(Widget child, {Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('Shows placeholder when BMI is 0', (tester) async {
    await tester.pumpWidget(
      _wrapWithApp(const BmiCard(bmi: 0, description: 'desc')),
    );

    expect(find.text('--'), findsOneWidget);
    expect(find.text('desc'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('Formats BMI with one decimal place', (tester) async {
    await tester.pumpWidget(
      _wrapWithApp(const BmiCard(bmi: 23.456, description: 'Normal range')),
    );

    expect(find.text('23.5'), findsOneWidget);
    expect(find.text('Normal range'), findsOneWidget);
  });

  testWidgets('Displays localized title in English', (tester) async {
    await tester.pumpWidget(
      _wrapWithApp(
        const BmiCard(bmi: 21.0, description: 'You have a normal weight.'),
        locale: const Locale('en'),
      ),
    );

    expect(find.text('Your current BMI'), findsOneWidget);
  });

  testWidgets('Displays localized title in Vietnamese', (tester) async {
    await tester.pumpWidget(
      _wrapWithApp(
        const BmiCard(bmi: 21.0, description: 'Bạn có cân nặng bình thường.'),
        locale: const Locale('vi'),
      ),
    );

    expect(find.text('BMI hiện tại của bạn'), findsOneWidget);
  });
}
