import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/record_view_home/data/models/food_record_model.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';

void main() {
  group('FoodRecordModel', () {
    test('fromJson parses scanType=barcode and Timestamp date', () {
      final timestamp = Timestamp.fromDate(DateTime(2025, 1, 2, 3, 4, 5));

      final model = FoodRecordModel.fromJson({
        'id': 'r1',
        'foodName': 'Apple',
        'calories': 95,
        'scanType': 'barcode',
        'scanDate': timestamp,
        'protein': 0.3,
        'carbs': 25,
        'fat': 0.2,
        'barcode': '012345',
      });

      expect(model.id, 'r1');
      expect(model.foodName, 'Apple');
      expect(model.calories, 95.0);
      expect(model.recordType, RecordType.barcode);
      expect(model.date, timestamp.toDate());
      expect(model.protein, 0.3);
      expect(model.carbs, 25.0);
      expect(model.fat, 0.2);
      expect(model.barcode, '012345');
    });

    test('fromJson parses scanType=food and string date', () {
      final model = FoodRecordModel.fromJson({
        'foodName': 'Salad',
        'calories': 123.4,
        'scanType': 'food',
        'scanDate': '2025-12-27T10:20:30.000Z',
      });

      expect(model.recordType, RecordType.food);
      expect(model.date.toUtc(), DateTime.parse('2025-12-27T10:20:30.000Z'));
    });

    test('fromJson uses recordType when present and falls back to text', () {
      final manual = FoodRecordModel.fromJson({
        'foodName': 'Rice',
        'calories': 200,
        'date': '2025-12-27T00:00:00.000Z',
        'recordType': 'manual',
      });
      expect(manual.recordType, RecordType.manual);

      final unknown = FoodRecordModel.fromJson({
        'foodName': 'Unknown',
        'calories': 0,
        'date': '2025-12-27T00:00:00.000Z',
        'recordType': 'not_a_real_type',
      });
      expect(unknown.recordType, RecordType.text);
    });

    test('fromJson defaults missing fields sensibly', () {
      final model = FoodRecordModel.fromJson({});

      expect(model.foodName, 'Unnamed Food');
      expect(model.calories, 0.0);
      expect(model.recordType, RecordType.text);
    });

    test('toJson writes Timestamp date and recordType name', () {
      final date = DateTime(2025, 12, 27, 9, 0, 0);
      final model = FoodRecordModel(
        id: 'x1',
        foodName: 'Yogurt',
        calories: 150,
        date: date,
        recordType: RecordType.manual,
        reason: 'Snack',
        nutritionDetails: 'protein-rich',
        protein: 10,
        carbs: 12,
        fat: 4,
        barcode: '999',
      );

      final json = model.toJson();

      expect(json['id'], 'x1');
      expect(json['foodName'], 'Yogurt');
      expect(json['calories'], 150.0);
      expect(json['recordType'], 'manual');
      expect(json['date'], isA<Timestamp>());
      expect((json['date'] as Timestamp).toDate(), date);
      expect(json['reason'], 'Snack');
      expect(json['nutritionDetails'], 'protein-rich');
      expect(json['protein'], 10.0);
      expect(json['carbs'], 12.0);
      expect(json['fat'], 4.0);
      expect(json['barcode'], '999');
    });

    test('fromEntity copies all fields', () {
      final entity = FoodRecordEntity(
        id: 'e1',
        foodName: 'Banana',
        calories: 105,
        date: DateTime(2025, 12, 27),
        imagePath: '/tmp/banana.png',
        recordType: RecordType.text,
        reason: 'Energy',
        nutritionDetails: 'Details',
        protein: 1.3,
        carbs: 27,
        fat: 0.3,
        barcode: '111',
      );

      final model = FoodRecordModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.foodName, entity.foodName);
      expect(model.calories, entity.calories);
      expect(model.date, entity.date);
      expect(model.imagePath, entity.imagePath);
      expect(model.recordType, entity.recordType);
      expect(model.reason, entity.reason);
      expect(model.nutritionDetails, entity.nutritionDetails);
      expect(model.protein, entity.protein);
      expect(model.carbs, entity.carbs);
      expect(model.fat, entity.fat);
      expect(model.barcode, entity.barcode);
    });
  });
}
