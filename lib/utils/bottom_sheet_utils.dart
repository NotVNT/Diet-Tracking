import 'package:flutter/material.dart';

/// A utility function to show a customized modal bottom sheet.
///
/// This wrapper standardizes the appearance of bottom sheets across the app.
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  Color? backgroundColor,
  ShapeBorder? shape,
  bool useSafeArea = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    shape: shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
  );
}
