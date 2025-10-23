import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/food_record_entity.dart';
import '../../domain/repositories/food_record_repository.dart';
import '../models/food_record_model.dart';
import '../../../../database/local_storage_service.dart';

class FoodRecordRepositoryImpl implements FoodRecordRepository {
  final LocalStorageService _localStorageService;
  final FirebaseFirestore _firestore;

  FoodRecordRepositoryImpl(
    this._localStorageService, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  static const _key = 'food_records';

  List<dynamic> _coerceToJsonList(dynamic data) {
    if (data == null) return <dynamic>[];
    if (data is List) return data;
    if (data is String) {
      final s = data.trim();
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) return decoded;
        // if decoded is a map wrap into list
        if (decoded is Map<String, dynamic>) return [decoded];
      } catch (_) {
        // swallow and fallback
      }
    }
    // Unknown format -> return empty
    return <dynamic>[];
  }

  Future<void> _saveToFirestore(FoodRecordModel model) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // chưa đăng nhập thì bỏ qua Firestore
    final uid = user.uid;
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('food_records')
        .doc(model.id);
    await docRef.set(model.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> saveFoodRecord(FoodRecordEntity foodRecord) async {
    final model = FoodRecordModel.fromEntity(foodRecord);

    // Read existing data robustly (handles legacy string storage)
    final raw = await _localStorageService.getData(_key);
    final currentList = _coerceToJsonList(raw)
        .map(
          (e) => FoodRecordModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    final updatedRecords = [...currentList, model];

    final jsonList = updatedRecords
        .map((record) => FoodRecordModel.fromEntity(record).toJson())
        .toList();

    await _localStorageService.saveData(_key, jsonList);

    // Save to Firestore in parallel (best-effort)
    try {
      await _saveToFirestore(model);
    } catch (_) {
      // Không chặn luồng nếu Firestore lỗi
    }
  }

  Future<List<FoodRecordModel>> _getFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return []; // chưa đăng nhập thì trả về empty

    try {
      final uid = user.uid;
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('food_records')
          .orderBy('date', descending: true) // sắp xếp theo thời gian mới nhất
          .get();

      return querySnapshot.docs
          .map((doc) => FoodRecordModel.fromJson({
                ...doc.data(),
                'id': doc.id, // đảm bảo có id
              }))
          .toList();
    } catch (e) {
      // Log error without using print in production
      // Consider using a proper logging framework
      return [];
    }
  }

  @override
  Future<List<FoodRecordEntity>> getFoodRecords() async {
    // Lấy dữ liệu từ Firebase trước
    final firestoreRecords = await _getFromFirestore();

    // Nếu có dữ liệu từ Firebase, đồng bộ với local storage
    if (firestoreRecords.isNotEmpty) {
      // Lấy dữ liệu local hiện tại
      final localData = await _localStorageService.getData(_key);
      final localList = _coerceToJsonList(localData);
      final localRecords = localList
          .whereType<Map>()
          .map((json) => FoodRecordModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Tạo map để merge dữ liệu (ưu tiên Firebase)
      final Map<String, FoodRecordModel> mergedRecords = {};

      // Thêm local records trước
      for (final record in localRecords) {
        if (record.id != null) {
          mergedRecords[record.id!] = record;
        }
      }

      // Override với Firebase records (ưu tiên Firebase)
      for (final record in firestoreRecords) {
        if (record.id != null) {
          mergedRecords[record.id!] = record;
        }
      }

      // Lưu dữ liệu đã merge vào local storage
      final jsonList = mergedRecords.values
          .map((record) => record.toJson())
          .toList();
      await _localStorageService.saveData(_key, jsonList);

      // Trả về danh sách đã sắp xếp theo thời gian
      final sortedRecords = mergedRecords.values.toList();
      sortedRecords.sort((a, b) => b.date.compareTo(a.date));
      return sortedRecords;
    }

    // Nếu không có dữ liệu từ Firebase, lấy từ local storage
    final data = await _localStorageService.getData(_key);
    final list = _coerceToJsonList(data);
    final localRecords = list
        .whereType<Map>()
        .map(
          (json) =>
              FoodRecordModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();

    // Sắp xếp theo thời gian mới nhất
    localRecords.sort((a, b) => b.date.compareTo(a.date));
    return localRecords;
  }

  /// Đồng bộ dữ liệu từ Firebase về local storage
  @override
  Future<void> syncWithFirestore() async {
    final firestoreRecords = await _getFromFirestore();
    if (firestoreRecords.isNotEmpty) {
      final jsonList = firestoreRecords
          .map((record) => record.toJson())
          .toList();
      await _localStorageService.saveData(_key, jsonList);
    }
  }

  @override
  Future<void> deleteFoodRecord(String id) async {
    final records = await getFoodRecords();
    final updatedRecords = records.where((record) => record.id != id).toList();

    final jsonList = updatedRecords
        .map((record) => FoodRecordModel.fromEntity(record).toJson())
        .toList();

    await _localStorageService.saveData(_key, jsonList);

    // Xóa trên Firestore nếu có đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('food_records')
          .doc(id)
          .delete()
          .catchError((_) {});
    }
  }
}
