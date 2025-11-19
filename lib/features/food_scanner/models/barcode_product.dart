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
