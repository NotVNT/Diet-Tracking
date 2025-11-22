import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/food_record_entity.dart';
import '../../domain/repositories/food_record_repository.dart';
import '../models/food_record_model.dart';

class FoodRecordRepositoryImpl implements FoodRecordRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FoodRecordRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> saveFoodRecord(FoodRecordEntity foodRecord) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot save record.');
    }

    // Generate a numeric ID based on timestamp if no ID is provided.
    final recordId =
        foodRecord.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('food_records')
        .doc(recordId);

    // Ensure the entity being saved has the correct ID.
    final entityWithId = foodRecord.copyWith(id: recordId);
    final model = FoodRecordModel.fromEntity(entityWithId);

    await docRef.set(model.toJson());
  }

  @override
  Future<List<FoodRecordEntity>> getFoodRecords() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('food_records')
          .get();

      final records = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FoodRecordModel.fromJson(data);
      }).toList();

      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (e) {
      debugPrint('Error fetching from food_records: $e');
      return [];
    }
  }

  @override
  Future<void> deleteFoodRecord(String id) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in. Cannot delete record.');
    }
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('food_records')
        .doc(id)
        .delete();
  }
}
