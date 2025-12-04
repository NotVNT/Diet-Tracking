import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/scanned_food_entity.dart';

// ============================================================================
// ENUMS
// ============================================================================

/// Supported scanner actions.
enum ScannerActionType { food, barcode, gallery }

// ============================================================================
// BARCODE PRODUCT MODEL
// ============================================================================

/// Model cho sản phẩm lấy từ OpenFoodFacts API qua barcode
class BarcodeProduct {
  final String barcode;
  final String? productName;
  final String? brands;
  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fat;
  final String? imageUrl;
  final String? ingredientsText;

  BarcodeProduct({
    required this.barcode,
    this.productName,
    this.brands,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.imageUrl,
    this.ingredientsText,
  });

  /// Parse từ JSON response của OpenFoodFacts API
  factory BarcodeProduct.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      throw Exception('Product data not found in response');
    }

    final nutriments = product['nutriments'] as Map<String, dynamic>?;

    return BarcodeProduct(
      barcode: json['barcode'] as String? ?? '',
      productName: product['product_name'] as String?,
      brands: product['brands'] as String?,
      calories: _parseDouble(nutriments?['energy-kcal']),
      protein: _parseDouble(nutriments?['proteins']),
      carbohydrates: _parseDouble(nutriments?['carbohydrates']),
      fat: _parseDouble(nutriments?['fat']),
      imageUrl: product['image_url'] as String?,
      ingredientsText: product['ingredients_text'] as String?,
    );
  }

  /// Helper để parse double an toàn
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Convert sang Map để dễ debug
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'productName': productName,
      'brands': brands,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'imageUrl': imageUrl,
      'ingredientsText': ingredientsText,
    };
  }

  @override
  String toString() {
    return 'BarcodeProduct(barcode: $barcode, name: $productName, '
        'brand: $brands, calories: $calories kcal)';
  }
}

// ============================================================================
// SCANNED FOOD MODEL
// ============================================================================

/// Model for scanned food with JSON serialization
class ScannedFoodModel extends ScannedFoodEntity {
  const ScannedFoodModel({
    super.id,
    required super.imagePath,
    required super.scanType,
    required super.scanDate,
    super.isProcessed,
    super.foodName,
    super.calories,
    super.description,
  });

  factory ScannedFoodModel.fromRecordJson(Map<String, dynamic> json) {
    return ScannedFoodModel(
      id: json['id'] as String?,
      imagePath: json['imagePath'] as String? ?? '',
      scanType: ScanType.values.firstWhere(
        (e) =>
            e.toString() == 'ScanType.${json['scanType'] as String? ?? 'food'}',
        orElse: () => ScanType.food,
      ),
      scanDate: (json['date'] as Timestamp? ?? Timestamp.now()).toDate(),
      isProcessed: json['isProcessed'] as bool? ?? false,
      foodName: json['foodName'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }

  /// Create from JSON
  factory ScannedFoodModel.fromJson(Map<String, dynamic> json) {
    return ScannedFoodModel(
      id: json['id'] as String?,
      imagePath: json['imagePath'] as String? ?? '',
      scanType: ScanType.values.firstWhere(
        (e) => e.name == json['scanType'],
        orElse: () => ScanType.food,
      ),
      scanDate: _parseDate(json['scanDate']),
      isProcessed: json['isProcessed'] as bool? ?? false,
      foodName: json['foodName'] as String?,
      calories: _parseDoubleValue(json['calories']),
      description: json['description'] as String?,
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'scanType': scanType.name,
      'scanDate': Timestamp.fromDate(scanDate),
      'isProcessed': isProcessed,
      'foodName': foodName,
      'calories': calories,
      'description': description,
    };
  }

  /// Create from entity
  factory ScannedFoodModel.fromEntity(ScannedFoodEntity entity) {
    return ScannedFoodModel(
      id: entity.id,
      imagePath: entity.imagePath,
      scanType: entity.scanType,
      scanDate: entity.scanDate,
      isProcessed: entity.isProcessed,
      foodName: entity.foodName,
      calories: entity.calories,
      description: entity.description,
    );
  }
}

// ============================================================================
// SCANNER ACTION CONFIG
// ============================================================================

/// Metadata describing each scanner action button.
class ScannerActionConfig {
  final ScannerActionType type;
  final String label;
  final IconData icon;

  const ScannerActionConfig({
    required this.type,
    required this.label,
    required this.icon,
  });
}
