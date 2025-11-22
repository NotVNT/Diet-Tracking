import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_scanner_models.dart';

/// Remote datasource that stores scanned food photos under the current user's document.
class ScannedFoodRemoteDataSource {
  static const String _usersCollection = 'users';

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final int maxStoredItems;

  ScannedFoodRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    this.maxStoredItems = 24,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> _requireUid() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User must be logged in to use the scanner feature.');
    }
    return uid;
  }

  Future<void> saveScannedFood(ScannedFoodModel food) async {
    final uid = await _requireUid();

    // Save to the 'food_records' subcollection to unify data
    final docRef = _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection(
          'food_records',
        ) // Match the subcollection used by the chatbot
        .doc(food.id); // Use the model's ID as the document ID

    final foodJson = food.toJson();
    foodJson.remove('id'); // Don't save ID inside the document itself

    // Add a 'source' field to distinguish scanned items
    foodJson['source'] = 'scanner';

    // Rename 'scanDate' to 'date' to match the FoodRecordEntity
    if (foodJson.containsKey('scanDate')) {
      foodJson['date'] = foodJson['scanDate'];
      foodJson.remove('scanDate');
    }

    // Rename 'foodName' if it exists, to match FoodRecordEntity
    if (foodJson.containsKey('name')) {
      foodJson['foodName'] = foodJson['name'];
      foodJson.remove('name');
    }

    await docRef.set(foodJson, SetOptions(merge: true));
  }

  Future<List<ScannedFoodModel>> getAllScannedFoods() async {
    final uid = await _requireUid();
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection('food_records')
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      // Add default values for fields that might be missing
      data['id'] = doc.id;
      data.putIfAbsent('foodName', () => 'Scanned Item');
      data.putIfAbsent('calories', () => 0.0);
      return ScannedFoodModel.fromRecordJson(data);
    }).toList();
  }

  Future<List<ScannedFoodModel>> getRecentScannedFoods({int limit = 10}) async {
    final models = await getAllScannedFoods();
    return models.take(limit).toList();
  }

  Future<void> deleteScannedFood(String id) async {
    final uid = await _requireUid();
    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection('food_records')
        .doc(id)
        .delete();
  }

  Future<void> clearAllScannedFoods() async {
    final uid = await _requireUid();
    final snapshot = await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection('food_records')
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> markAsProcessed(String id) async {
    final uid = await _requireUid();
    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .collection('food_records')
        .doc(id)
        .update({'isProcessed': true});
  }
}
