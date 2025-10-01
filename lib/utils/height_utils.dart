import 'package:intl/intl.dart';

String getFormattedDate() {
  return DateFormat('MMM dd, yyyy').format(DateTime.now()); // Sep 30, 2025
}

String convertToFeetInches(double cm) {
  double totalInches = cm / 2.54;
  int feet = (totalInches / 12).floor();
  int inches = (totalInches % 12).round();
  return "$feet'$inches\"";
}

// Convert cm to feet and inches
Map<String, int> cmToFeetInches(double cm) {
  double totalInches = cm / 2.54;
  int feet = (totalInches / 12).floor();
  int inches = (totalInches % 12).round();
  return {'feet': feet, 'inches': inches};
}

// Convert feet and inches to cm
double feetInchesToCm(int feet, double inches) {
  double totalInches = (feet * 12) + inches;
  return totalInches * 2.54;
}

// Format height display based on unit
String formatHeight(double height, bool isCm) {
  if (isCm) {
    return '${height.toStringAsFixed(1)} cm';
  } else {
    final feetInches = cmToFeetInches(height);
    return "${feetInches['feet']}'${feetInches['inches']}\"";
  }
}

// Convert centimeters to decimal feet (e.g. 172 cm -> 5.64 ft)
double cmToDecimalFeet(double cm) {
  final totalInches = cm / 2.54;
  return totalInches / 12.0;
}
