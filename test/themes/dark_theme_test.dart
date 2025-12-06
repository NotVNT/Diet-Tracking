import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/themes/dark_theme.dart';

void main() {
  testWidgets('AppDarkTheme provides dark brightness and expected colors', (tester) async {
    late ThemeData theme;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDarkTheme.theme,
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, const Color(0xFF818CF8));
    expect(theme.colorScheme.secondary, const Color(0xFF34D399));
    expect(theme.scaffoldBackgroundColor, const Color(0xFF111827));

    // TextTheme colors
    expect(theme.textTheme.displayLarge?.color, const Color(0xFFF9FAFB));
    expect(theme.textTheme.bodyMedium?.color, const Color(0xFF9CA3AF));

    // InputDecoration should be filled with dark fill color
    expect(theme.inputDecorationTheme.filled, true);
    expect(theme.inputDecorationTheme.fillColor, const Color(0xFF374151));
  });
}

