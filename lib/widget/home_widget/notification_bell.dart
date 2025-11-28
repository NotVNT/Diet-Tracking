import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

class NotificationBell extends StatelessWidget {
  final int notificationCount;
  final VoidCallback onTap;

    const NotificationBell({
    super.key,
    this.notificationCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: -5, end: -5),
        badgeAnimation: const badges.BadgeAnimation.scale(
          animationDuration: Duration(milliseconds: 300),
        ),
        showBadge: notificationCount > 0,
        badgeContent: Text(
          '$notificationCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Icon(
          Icons.notifications_none_outlined,
          size: 30,
        ),
      ),
    );
  }
}

