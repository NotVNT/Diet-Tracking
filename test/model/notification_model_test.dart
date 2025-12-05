import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diet_tracking_project/model/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('toMap should include all fields', () {
      final now = DateTime.now();
      final model = NotificationModel(
        id: 'id-1',
        title: 'Title',
        body: 'Body',
        timestamp: now,
        isRead: true,
      );

      final map = model.toMap();
      expect(map['title'], 'Title');
      expect(map['body'], 'Body');
      expect(map['timestamp'], now);
      expect(map['isRead'], true);
    });

    test('fromMap parses Timestamp correctly and defaults isRead=false', () {
      final ts = Timestamp.fromDate(DateTime(2024, 1, 2, 3, 4, 5));
      final map = {
        'title': 'Hello',
        'body': 'World',
        'timestamp': ts,
        // isRead omitted
      };

      final model = NotificationModel.fromMap(map, 'doc-123');
      expect(model.id, 'doc-123');
      expect(model.title, 'Hello');
      expect(model.body, 'World');
      expect(model.timestamp, ts.toDate());
      expect(model.isRead, false);
    });

    test('fromMap parses isRead when provided', () {
      final ts = Timestamp.now();
      final map = {
        'title': 'T',
        'body': 'B',
        'timestamp': ts,
        'isRead': true,
      };
      final model = NotificationModel.fromMap(map, 'x');
      expect(model.isRead, true);
    });

    test('copyWith updates only provided fields', () {
      final now = DateTime(2024, 5, 6);
      final model = NotificationModel(
        id: 'id',
        title: 't1',
        body: 'b1',
        timestamp: now,
      );

      final updated = model.copyWith(title: 't2', isRead: true);
      expect(updated.id, 'id');
      expect(updated.title, 't2');
      expect(updated.body, 'b1');
      expect(updated.timestamp, now);
      expect(updated.isRead, true);
    });
  });
}

