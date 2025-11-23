import 'package:flutter/material.dart';

class NotificationBell extends StatelessWidget {
  final int notificationCount;
  final VoidCallback onTap;

  const NotificationBell({
    Key? key,
    this.notificationCount = 0,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.notifications_none_outlined,
            size: 30,
          ),
          if (notificationCount > 0)
            Positioned(
              top: 4,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '$notificationCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

