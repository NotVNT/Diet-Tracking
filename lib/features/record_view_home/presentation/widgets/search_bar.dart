import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../responsive/responsive.dart';

/// SearchBar with optional debounce and clear button
class SearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final Duration debounce;
  final bool autofocus;
  final Widget? trailing;

  const SearchBar({
    super.key,
    this.controller,
    this.onSearchChanged,
    this.onSubmitted,
    this.hintText,
    this.debounce = const Duration(milliseconds: 350),
    this.autofocus = false,
    this.trailing,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _hasText = _controller.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value) {
    if (widget.onSearchChanged == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onSearchChanged?.call(value.trim());
    });
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onSearchChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        // Search field
        Expanded(
          child: Container(
            height: responsive.height(48),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(responsive.radius(12)),
            ),
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              onChanged: _onChanged,
              onSubmitted: (v) => widget.onSubmitted?.call(v.trim()),
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText ?? localizations?.searchHintText ?? 'Tìm kiếm',
                hintStyle: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: responsive.iconSize(20),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                suffixIcon: _hasText
                    ? IconButton(
                        tooltip: localizations?.dataSyncClearCacheDialogConfirm ?? 'Clear',
                        icon: Icon(
                          Icons.close_rounded,
                          size: responsive.iconSize(18),
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onPressed: _clear,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: responsive.width(16),
                  vertical: responsive.height(12),
                ),
              ),
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          SizedBox(width: responsive.width(8)),
          widget.trailing!,
        ]
      ],
    );
  }
}
