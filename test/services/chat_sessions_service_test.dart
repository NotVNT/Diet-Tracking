import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/services/chat_sessions_service.dart';

void main() {
  group('ChatSessionsService text helpers', () {
    test('buildPreview trims, squashes whitespace, and truncates to 50 chars', () {
      final service = ChatSessionsService(
        db: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(signedIn: false),
      );

      expect(service.buildPreview('   a   b\n\n c  '), 'a b c');

      final long = 'x' * 60;
      final preview = service.buildPreview(long);
      expect(preview.length, 51);
      expect(preview.endsWith('…'), isTrue);
      expect(preview.substring(0, 50), 'x' * 50);
    });

    test('buildTitle trims and truncates to 30 chars', () {
      final service = ChatSessionsService(
        db: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(signedIn: false),
      );

      expect(service.buildTitle('   Hello  '), 'Hello');

      final long = 'y' * 40;
      final title = service.buildTitle(long);
      expect(title.length, 31);
      expect(title.endsWith('…'), isTrue);
      expect(title.substring(0, 30), 'y' * 30);
    });
  });

  group('ChatSessionsService auth and Firestore interaction', () {
    test('streamSessionsForCurrentUser throws when not signed in', () {
      final service = ChatSessionsService(
        db: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(signedIn: false),
      );

      expect(() => service.streamSessionsForCurrentUser(), throwsException);
    });

    test('getMostRecentSession returns null when not signed in (swallows)', () async {
      final service = ChatSessionsService(
        db: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(signedIn: false),
      );

      final session = await service.getMostRecentSession();
      expect(session, isNull);
    });

    test('streamSessionsForCurrentUser orders by lastMessageAt desc and limits 5', () async {
      final db = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final service = ChatSessionsService(db: db, auth: auth);

      final col = db.collection('users').doc('u1').collection('chat_sessions');
      // Create 6 sessions; stream should return only 5.
      for (var i = 0; i < 6; i++) {
        await col.doc('s$i').set({
          'title': 't$i',
          'lastMessagePreview': 'p$i',
          'createdAt': Timestamp.fromDate(DateTime(2020, 1, 1).add(Duration(days: i))),
          'lastMessageAt': Timestamp.fromDate(DateTime(2020, 1, 1).add(Duration(days: i))),
          'messageCount': i,
        });
      }

      final stream = service.streamSessionsForCurrentUser();

      await expectLater(
        stream,
        emits(
          predicate<List<ChatSessionFS>>((list) {
            if (list.length != 5) return false;
            // Most recent should be s5 (day 5) but limited to 5, so s5..s1.
            return list.first.id == 's5' && list.last.id == 's1';
          }),
        ),
      );
    });

    test('createSession enforces max 5 when autoDeleteOldest=false', () async {
      final db = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final service = ChatSessionsService(db: db, auth: auth);

      final col = db.collection('users').doc('u1').collection('chat_sessions');
      for (var i = 0; i < 5; i++) {
        await col.doc('s$i').set({
          'title': 't$i',
          'lastMessagePreview': 'p$i',
          'createdAt': Timestamp.fromDate(DateTime(2020, 1, 1).add(Duration(days: i))),
          'lastMessageAt': Timestamp.fromDate(DateTime(2020, 1, 1).add(Duration(days: i))),
          'messageCount': i,
        });
      }

      expect(
        () => service.createSession(autoDeleteOldest: false),
        throwsException,
      );
    });
  });
}
