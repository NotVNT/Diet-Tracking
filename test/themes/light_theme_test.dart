import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/themes/light_theme.dart';

void main() {
  testWidgets('AppLightTheme provides light brightness and expected colors', (tester) async {
    late ThemeData theme;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppLightTheme.theme,
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, const Color(0xFF6366F1));
    expect(theme.colorScheme.secondary, const Color(0xFF10B981));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F7FB));

    // Check some text theme entries exist and have colors
    expect(theme.textTheme.displayLarge?.color, const Color(0xFF111827));
    expect(theme.textTheme.labelLarge?.color, Colors.white);

    // InputDecoration should have filled true with white fill
    expect(theme.inputDecorationTheme.filled, true);
    expect(theme.inputDecorationTheme.fillColor, Colors.white);
  });
}

