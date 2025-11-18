import '../../domain/entities/scanned_food_entity.dart';

/// Model for scanned food with JSON serialization
class ScannedFoodModel extends ScannedFoodEntity {
  const ScannedFoodModel({
    required super.id,
    required super.imagePath,
    required super.scanType,
    required super.scanDate,
    super.isProcessed,
  });

  /// Create from JSON
  factory ScannedFoodModel.fromJson(Map<String, dynamic> json) {
    final imagePath = json['imagePath'] as String? ?? '';
    return ScannedFoodModel(
      id: (json['id'] as String?) ?? imagePath,
      imagePath: imagePath,
      scanType: ScanType.values.firstWhere(
        (e) => e.name == json['scanType'],
        orElse: () => ScanType.food,
      ),
      scanDate: _parseDate(json['scanDate']),
      isProcessed: json['isProcessed'] as bool? ?? false,
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'scanType': scanType.name,
      'scanDate': scanDate.toIso8601String(),
      'isProcessed': isProcessed,
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
    );
  }
}
