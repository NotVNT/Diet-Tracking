import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


/// Simple wrapper for local notifications used in the app
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() => _instance;

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Track whether water reminder for this session has been scheduled
  bool _waterReminderScheduledThisSession = false;

  /// Call this when user logs out or a new login session starts
  void resetWaterReminderSessionFlag() {
    _waterReminderScheduledThisSession = false;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Timezone initialization for zoned scheduling
    tz.initializeTimeZones();

    // Create a default channel for Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'diet_tracking_default_channel',
        'Diet Tracking Notifications',
        description: 'General notifications for Diet Tracking',
        importance: Importance.defaultImportance,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'diet_tracking_default_channel',
      'Diet Tracking Notifications',
      channelDescription: 'General notifications for Diet Tracking',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      0,
      title,
      body,
      details,
    );
  }

  /// Schedule a one-time water reminder for this app session
  Future<void> scheduleWaterReminderOncePerSession({
    Duration delay = const Duration(seconds: 30),
  }) async {
    if (_waterReminderScheduledThisSession) return;

    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'diet_tracking_default_channel',
      'Diet Tracking Notifications',
      channelDescription: 'General notifications for Diet Tracking',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      2001,
      'Nhắc nhở uống nước',
      'Đừng quên uống nước! Hãy uống một ly nước ngay bây giờ để giữ cơ thể luôn đủ ẩm và tràn đầy năng lượng',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'water_reminder_once_per_session',
      matchDateTimeComponents: null,
    );

    _waterReminderScheduledThisSession = true;
  }
}


