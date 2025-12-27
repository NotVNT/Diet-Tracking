import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/utils/logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLogger', () {
    late DebugPrintCallback originalDebugPrint;
    late List<String> logs;

    setUp(() {
      logs = <String>[];
      originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) logs.add(message);
      };
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
    });

    test('debug uses default tag and prefix', () {
      AppLogger.debug('hello');
      expect(logs, ['[AppLogger] hello']);
    });

    test('info/warning respect custom tag', () {
      AppLogger.info('i', tag: 'TAG');
      AppLogger.warning('w', tag: 'TAG');

      expect(logs, ['[TAG] i', '[TAG] w']);
    });

    test('error logs message only when no error/stackTrace provided', () {
      AppLogger.error('boom', tag: 'T');
      expect(logs, ['[T] boom']);
    });

    test('error logs message, error, and stackTrace when provided', () {
      final st = StackTrace.current;

      AppLogger.error(
        'boom',
        tag: 'T',
        error: 'E',
        stackTrace: st,
      );

      expect(logs.length, 3);
      expect(logs[0], '[T] boom');
      expect(logs[1], '[T] Error: E');
      expect(logs[2], startsWith('[T] StackTrace: '));
    });
  });
}
