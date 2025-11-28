import 'package:flutter/material.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

/// Simple, friendly confirmation dialog for the app with localization support.
///
/// Usage:
/// final confirmed = await showAppConfirmDialog(
///   context,
///   title: 'Xác nhận',
///   message: 'Bạn có chắc muốn xóa mục này?',
///   destructive: true,
/// );
/// if (confirmed == true) { /* do action */ }
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.destructive = false,
    this.icon,
    this.iconColor,
    this.extraContent,
  });

  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final bool destructive;
  final IconData? icon;
  final Color? iconColor;
  final Widget? extraContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final Color confirmBg = destructive ? cs.error : cs.primary;
    final Color confirmFg = destructive ? cs.onError : cs.onPrimary;

    // Localized fallback labels
    final String cancelLabel = cancelText ?? (l10n?.cancel ?? 'Cancel');
    final String confirmLabel = confirmText ?? (
      destructive
          ? (l10n?.delete ?? 'Delete')
          : (l10n?.done ?? 'Done')
    );

    return AlertDialog(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: (iconColor ?? (destructive ? cs.errorContainer : cs.primaryContainer)),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon ?? (destructive ? Icons.warning_amber_rounded : Icons.help_rounded),
              size: 22,
              color: destructive ? cs.onErrorContainer : cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyLarge,
          ),
          if (extraContent != null) ...[
            const SizedBox(height: 12),
            extraContent!,
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: confirmBg,
            foregroundColor: confirmFg,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).maybePop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// Helper to show the confirmation dialog quickly.
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  bool destructive = false,
  IconData? icon,
  Color? iconColor,
  Widget? extraContent,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AppConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      destructive: destructive,
      icon: icon,
      iconColor: iconColor,
      extraContent: extraContent,
    ),
  );
}

