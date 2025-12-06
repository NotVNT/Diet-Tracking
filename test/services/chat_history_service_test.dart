import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/services/chat_history_service.dart';

void main() {
  group('ChatMessage serialization', () {
    test('toMap uses UTC ISO8601', () {
      final dt = DateTime.utc(2024, 1, 2, 3, 4, 5);
      final msg = ChatMessage(role: 'user', content: 'hi', timestamp: dt);
      final m = msg.toMap();
      expect(m['role'], 'user');
      expect(m['content'], 'hi');
      expect(m['timestamp'], dt.toIso8601String());
    });

    test('fromMap parses and defaults correctly', () {
      final dt = DateTime.utc(2024, 5, 6, 7, 8, 9).toIso8601String();
      final msg = ChatMessage.fromMap({
        'role': 'model',
        'content': 'ok',
        'timestamp': dt,
      });
      expect(msg.role, 'model');
      expect(msg.content, 'ok');
      expect(msg.timestamp.isUtc, true);
      expect(msg.timestamp, DateTime.parse(dt).toUtc());

      // Missing fields
      final fallback = ChatMessage.fromMap({});
      expect(fallback.role, 'user');
      expect(fallback.content, '');
      // timestamp falls back to now (UTC); we only assert it's close to now
      final now = DateTime.now().toUtc();
      expect(fallback.timestamp.difference(now).inSeconds.abs() < 5, true);
    });
  });
}

