import 'package:diet_tracking_project/widget/health/allergy_selection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Material(child: child),
    ),
  );
}

class _StateHarness extends StatefulWidget {
  const _StateHarness({required this.initial});
  final List<String> initial;

  @override
  State<_StateHarness> createState() => _StateHarnessState();
}

class _StateHarnessState extends State<_StateHarness> {
  late List<String> allergies;

  @override
  void initState() {
    super.initState();
    allergies = List<String>.from(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return AllergySelectionCard(
      selectedAllergies: allergies,
      onAllergiesChanged: (newList) {
        setState(() => allergies = newList);
      },
    );
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AllergySelectionCard', () {
    testWidgets('shows empty state when no allergies', (tester) async {
      await tester.pumpWidget(_wrap(const _StateHarness(initial: [])));

      expect(find.text('Dị Ứng Thực Phẩm'), findsOneWidget);
      expect(find.text('Chưa có dị ứng nào'), findsOneWidget);
      expect(find.text('+ Thêm'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('adds allergy from free text and can remove it', (tester) async {
      await tester.pumpWidget(_wrap(const _StateHarness(initial: [])));

      await tester.enterText(find.byType(TextField), 'Peanuts');
      await tester.pump();

      await tester.tap(find.text('+ Thêm'));
      await tester.pump();

      // Unknown allergy uses default emoji.
      expect(find.text('🍽️ Peanuts'), findsOneWidget);
      expect(find.text('Chưa có dị ứng nào'), findsNothing);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('🍽️ Peanuts'), findsNothing);
      expect(find.text('Chưa có dị ứng nào'), findsOneWidget);
    });

    testWidgets('normalizes input without diacritics to common allergy option',
        (tester) async {
      await tester.pumpWidget(_wrap(const _StateHarness(initial: [])));

      await tester.enterText(find.byType(TextField), 'hai san');
      await tester.pump();

      await tester.tap(find.text('+ Thêm'));
      await tester.pump();

      // Should match common list "Hải sản" and show its emoji.
      expect(find.text('🦞 Hải sản'), findsOneWidget);
    });
  });
}
