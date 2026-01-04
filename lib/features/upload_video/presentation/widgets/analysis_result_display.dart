import 'package:flutter/material.dart';

class AnalysisResultDisplay extends StatelessWidget {
  final String text;

  const AnalysisResultDisplay({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildContentWidgets(context),
    );
  }

  List<Widget> _buildContentWidgets(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    var currentTextBuffer = StringBuffer();

    void flushBuffer() {
      if (currentTextBuffer.isNotEmpty) {
        widgets.add(_buildRichText(
          context,
          currentTextBuffer.toString().trim(),
        ));
        widgets.add(const SizedBox(height: 12));
        currentTextBuffer.clear();
      }
    }

    for (var line in lines) {
      final cleanedLine = line.replaceAll('#', '');
      final trimmedLine = cleanedLine.trim();

      if (trimmedLine.isEmpty) continue;

      if (trimmedLine.startsWith(RegExp(r'^[\*\-]\s'))) {
        flushBuffer();
        String content = trimmedLine.replaceFirst(RegExp(r'^[\*\-]\s'), '');
        widgets.add(_buildCardItem(context, content));
        widgets.add(const SizedBox(height: 12));
      } else if (trimmedLine.startsWith(RegExp(
          r'^(Lưu ý|Mẹo|Gợi ý|Lời khuyên|Kết luận|Chú ý)',
          caseSensitive: false))) {
        flushBuffer();
        widgets.add(Text(
          trimmedLine,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ));
        widgets.add(const SizedBox(height: 8));
      } else {
        currentTextBuffer.writeln(cleanedLine);
      }
    }

    flushBuffer();

    if (widgets.isNotEmpty && widgets.last is SizedBox) {
      widgets.removeLast();
    }

    return widgets;
  }

  Widget _buildCardItem(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: _buildRichText(context, content),
    );
  }

  Widget _buildRichText(BuildContext context, String text) {
    final parts = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.5,
        );

    final boldStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        parts.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      parts.add(TextSpan(
        text: match.group(1),
        style: boldStyle,
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: parts),
    );
  }
}
