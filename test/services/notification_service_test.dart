import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalNotificationService', () {
    const channelNames = <String>[
      // Common channel name for flutter_local_notifications
      'dexterous.com/flutter/local_notifications',
      // Fallbacks (harmless if unused)
      'flutter_local_notifications',
    ];

    late List<MethodCall> calls;

    setUp(() {
      calls = <MethodCall>[];
      for (final name in channelNames) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MethodChannel(name), (call) async {
          calls.add(call);
          // Most plugin methods return a boolean or null; returning null is fine
          // for our tests as long as it doesn't throw.
          return true;
        });
      }

      // Reset singleton state between tests.
      LocalNotificationService().resetWaterReminderSessionFlag();
    });

    tearDown(() {
      for (final name in channelNames) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MethodChannel(name), null);
      }
    });

    test('showSimpleNotification triggers plugin show after initialize', () async {
      final svc = LocalNotificationService();

      await svc.showSimpleNotification(title: 'T', body: 'B');

      // Should have called initialize + show.
      expect(calls.any((c) => c.method.toLowerCase().contains('initialize')),
          isTrue);
      expect(calls.any((c) => c.method == 'show'), isTrue);
    });

    test('scheduleWaterReminderOncePerSession schedules only once per session',
        () async {
      final svc = LocalNotificationService();

      await svc.scheduleWaterReminderOncePerSession(
        delay: const Duration(seconds: 1),
      );
      await svc.scheduleWaterReminderOncePerSession(
        delay: const Duration(seconds: 1),
      );

      final scheduleCalls = calls.where((c) => c.method == 'zonedSchedule');
      expect(scheduleCalls.length, 1);

      // After reset, should schedule again.
      svc.resetWaterReminderSessionFlag();
      await svc.scheduleWaterReminderOncePerSession(
        delay: const Duration(seconds: 1),
      );
      final scheduleCallsAfterReset = calls.where((c) => c.method == 'zonedSchedule');
      expect(scheduleCallsAfterReset.length, 2);
    });
  });
}
