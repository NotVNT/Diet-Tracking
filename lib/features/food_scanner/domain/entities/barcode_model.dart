/// Barcode model that wraps barcode package data
/// This maintains compatibility with existing code while using the barcode package
class BarcodeModel {
  final String? rawValue;
  final String? displayValue;
  final BarcodeFormat format;
  final BarcodeValueType valueType;

  BarcodeModel({
    required this.rawValue,
    this.displayValue,
    required this.format,
    required this.valueType,
  });

  /// Get the barcode value (prefer displayValue over rawValue)
  String? get value => displayValue ?? rawValue;

  @override
  String toString() => 'BarcodeModel(value: $value, format: $format)';
}

/// Barcode format enum
enum BarcodeFormat {
  unknown,
  code128,
  code39,
  code93,
  codabar,
  dataMatrix,
  ean13,
  ean8,
  itf,
  qrCode,
  pdf417,
  aztec,
}

/// Barcode value type enum
enum BarcodeValueType {
  unknown,
  contactInfo,
  email,
  isbn,
  phone,
  product,
  sms,
  text,
  url,
  wifi,
  geographicCoordinates,
  calendarEvent,
  driverLicense,
}

/// Extension to convert barcode package format to our enum
extension BarcodeFormatExtension on String {
  BarcodeFormat toBarcodeFormat() {
    switch (toLowerCase()) {
      case 'code128':
        return BarcodeFormat.code128;
      case 'code39':
        return BarcodeFormat.code39;
      case 'code93':
        return BarcodeFormat.code93;
      case 'codabar':
        return BarcodeFormat.codabar;
      case 'datamatrix':
        return BarcodeFormat.dataMatrix;
      case 'ean13':
        return BarcodeFormat.ean13;
      case 'ean8':
        return BarcodeFormat.ean8;
      case 'itf':
        return BarcodeFormat.itf;
      case 'qrcode':
        return BarcodeFormat.qrCode;
      case 'pdf417':
        return BarcodeFormat.pdf417;
      case 'aztec':
        return BarcodeFormat.aztec;
      default:
        return BarcodeFormat.unknown;
    }
  }
}

