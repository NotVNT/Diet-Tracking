import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/record_view_home/data/repositories/food_record_repository_impl.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';

void main() {
  group('FoodRecordRepositoryImpl (data layer)', () {
    test('saveFoodRecord throws when user not logged in', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(signedIn: false);
      final repo = FoodRecordRepositoryImpl(firestore: firestore, auth: auth);

      await expectLater(
        () => repo.saveFoodRecord(
          FoodRecordEntity(
            foodName: 'Apple',
            calories: 95,
            date: DateTime(2025, 12, 27),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('saveFoodRecord writes under user/food_records with provided id',
        () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final repo = FoodRecordRepositoryImpl(firestore: firestore, auth: auth);

      final date = DateTime(2025, 12, 27, 12, 0, 0);
      await repo.saveFoodRecord(
        FoodRecordEntity(
          id: 'r1',
          foodName: 'Salad',
          calories: 123.4,
          date: date,
          recordType: RecordType.manual,
          protein: 10,
          carbs: 20,
          fat: 5,
        ),
      );

      final snap = await firestore
          .collection('users')
          .doc('u1')
          .collection('food_records')
          .doc('r1')
          .get();

      expect(snap.exists, isTrue);
      final data = snap.data()!;
      expect(data['id'], 'r1');
      expect(data['foodName'], 'Salad');
      expect(data['calories'], 123.4);
      expect(data['recordType'], 'manual');
      expect(data['date'], isA<Timestamp>());
      expect((data['date'] as Timestamp).toDate(), date);
      expect(data['protein'], 10.0);
      expect(data['carbs'], 20.0);
      expect(data['fat'], 5.0);
    });

    test('saveFoodRecord generates id when null and persists it', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final repo = FoodRecordRepositoryImpl(firestore: firestore, auth: auth);

      await repo.saveFoodRecord(
        FoodRecordEntity(
          id: null,
          foodName: 'Banana',
          calories: 105,
          date: DateTime(2025, 12, 27),
        ),
      );

      final query = await firestore
          .collection('users')
          .doc('u1')
          .collection('food_records')
          .get();

      expect(query.docs, hasLength(1));
      final doc = query.docs.single;
      final data = doc.data();
      expect(doc.id, isNotEmpty);
      expect(data['id'], doc.id);
      expect(data['foodName'], 'Banana');
    });

    test('getFoodRecords returns [] when user null', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(signedIn: false);
      final repo = FoodRecordRepositoryImpl(firestore: firestore, auth: auth);

      final records = await repo.getFoodRecords();
      expect(records, isEmpty);
    });

    test('getFoodRecords reads docs, injects id, and sorts by date desc',
        () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final repo = FoodRecordRepositoryImpl(firestore: firestore, auth: auth);

      final col = firestore
          .collection('users')
          .doc('u1')
          .collection('food_records');

      await col.doc('old').set({
        'foodName': 'Old',
        'calories': 1,
        'date': Timestamp.fromDate(DateTime(2025, 1, 1)),
        'recordType': 'text',
      });

      await col.doc('new').set({
        'foodName': 'New',
        'calories': 2,
        'date': Timestamp.fromDate(DateTime(2025, 12, 27)),
        'recordType': 'text',
      });

      final records = await repo.getFoodRecords();

      expect(records, hasLength(2));
      expect(records.first.id, 'new');
      expect(records.first.foodName, 'New');
      expect(records.last.id, 'old');
      expect(records.last.foodName, 'Old');
    });

    test('deleteFoodRecord throws when user not logged in', () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(signedIn: false);
      final repo = FoodRecordRepositoryImpl(firestore: firestore, auth: auth);

      await expectLater(
        () => repo.deleteFoodRecord('r1'),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteFoodRecord deletes the document for signed-in user',
        () async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );
      final repo = FoodRecordRepositoryImpl(firestore: firestore, auth: auth);

      final docRef = firestore
          .collection('users')
          .doc('u1')
          .collection('food_records')
          .doc('r1');

      await docRef.set({
        'foodName': 'ToDelete',
        'calories': 10,
        'date': Timestamp.fromDate(DateTime(2025, 12, 27)),
        'recordType': 'text',
      });

      expect((await docRef.get()).exists, isTrue);

      await repo.deleteFoodRecord('r1');

      expect((await docRef.get()).exists, isFalse);
    });
  });
}
