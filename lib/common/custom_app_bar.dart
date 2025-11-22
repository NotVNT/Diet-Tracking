import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view/notification/notification_view.dart';
import '../responsive/responsive.dart';
import '../widget/home_widget/notification_bell.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final responsive = ResponsiveHelper.of(context);
    final resolvedBackground = backgroundColor ?? colorScheme.surfaceContainerHighest;
    final resolvedIconColor = colorScheme.onSurface;

    return AppBar(
      backgroundColor: resolvedBackground,
      foregroundColor: resolvedIconColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: resolvedIconColor,
          fontSize: responsive.fontSize(20),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: NotificationBell(
            notificationCount: 3, // Dummy count for demonstration
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationView()),
              );
            },
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
