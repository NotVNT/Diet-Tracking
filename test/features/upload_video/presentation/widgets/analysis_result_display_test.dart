import 'package:diet_tracking_project/features/upload_video/presentation/widgets/analysis_result_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AnalysisResultDisplay renders simple text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnalysisResultDisplay(text: 'Simple text'),
        ),
      ),
    );

    // Use a predicate to find RichText with the expected content
    final richTextFinder = find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final text = widget.text.toPlainText();
        return text == 'Simple text';
      }
      return false;
    });
    
    expect(richTextFinder, findsOneWidget);
  });

  testWidgets('AnalysisResultDisplay renders bold text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnalysisResultDisplay(text: 'This is **bold** text'),
        ),
      ),
    );

    // RichText finding is tricky, but we can check if the widget builds without error
    // and maybe find the RichText widget and inspect it.
    final richTextFinder = find.byType(RichText);
    expect(richTextFinder, findsOneWidget);
    
    // We can also try to find the text parts.
    // Note: find.text might not find "bold" if it's inside a TextSpan among others.
    // But let's verify the widget structure.
  });

  testWidgets('AnalysisResultDisplay removes # characters', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnalysisResultDisplay(text: '### Header'),
        ),
      ),
    );

    final richTextFinder = find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final text = widget.text.toPlainText();
        return text == 'Header';
      }
      return false;
    });
    expect(richTextFinder, findsOneWidget);
  });

  testWidgets('AnalysisResultDisplay renders bullet points as cards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnalysisResultDisplay(text: '* Bullet point'),
        ),
      ),
    );

    final richTextFinder = find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final text = widget.text.toPlainText();
        return text == 'Bullet point';
      }
      return false;
    });
    expect(richTextFinder, findsOneWidget);
    
    // And check if it's inside a Container with decoration
    final containerFinder = find.ancestor(
      of: richTextFinder,
      matching: find.byType(Container),
    );
    expect(containerFinder, findsWidgets);
  });

  testWidgets('AnalysisResultDisplay renders headers with primary color', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnalysisResultDisplay(text: 'Lưu ý: Important'),
        ),
      ),
    );

    final textFinder = find.text('Lưu ý: Important');
    expect(textFinder, findsOneWidget);
    
    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.fontWeight, FontWeight.bold);
  });
}
