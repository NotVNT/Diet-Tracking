import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/widget/height/height_scale_painter.dart';

Future<ui.Image> _paintToImage({
  required CustomPainter painter,
  required Size size,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  return image;
}

Future<List<int>> _readRgbaBytes(ui.Image image) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) {
    return <int>[];
  }
  return byteData.buffer.asUint8List();
}

int _rgbaAt(List<int> rgbaBytes, int width, int x, int y) {
  final idx = (y * width + x) * 4;
  final r = rgbaBytes[idx + 0];
  final g = rgbaBytes[idx + 1];
  final b = rgbaBytes[idx + 2];
  final a = rgbaBytes[idx + 3];
  return (a << 24) | (r << 16) | (g << 8) | b;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('paints selected indicator at expected Y in cm mode', () async {
    const width = 100;
    const height = 100;
    const min = 0.0;
    const max = 100.0;
    const selected = 50.0; // middle

    final painter = HeightScalePainter(
      selectedHeight: selected,
      minHeight: min,
      maxHeight: max,
      isCm: true,
      indicatorLength: 80,
    );

    final image = await _paintToImage(
      painter: painter,
      size: Size(width.toDouble(), height.toDouble()),
    );
    final rgba = await _readRgbaBytes(image);

    // Expected Y for middle selection: height - ((50-0)/(100-0)*100) = 50
    const expectedY = 50;
    // Sample a few x along the indicator line to be robust to AA
    const sampleXs = <int>[2, 10, 40, 75];
    for (final x in sampleXs) {
      final pixel = _rgbaAt(rgba, width, x, expectedY);
      expect(pixel, equals(Color(0xFF8B5CF6).value));
    }
  });

  test('paints selected indicator at expected Y in feet mode', () async {
    const width = 100;
    const height = 100;
    // 0.0 ft .. 1.0 ft mapped by cm inputs
    const minCm = 0.0;
    const maxCm = 30.48; // 1 ft
    const selectedCm = 15.24; // 0.5 ft -> middle

    final painter = HeightScalePainter(
      selectedHeight: selectedCm,
      minHeight: minCm,
      maxHeight: maxCm,
      isCm: false,
      indicatorLength: 80,
    );

    final image = await _paintToImage(
      painter: painter,
      size: Size(width.toDouble(), height.toDouble()),
    );
    final rgba = await _readRgbaBytes(image);

    const expectedY = 50;
    const sampleXs = <int>[2, 20, 60, 79];
    for (final x in sampleXs) {
      final pixel = _rgbaAt(rgba, width, x, expectedY);
      expect(pixel, equals(Color(0xFF8B5CF6).value));
    }
  });

  test('draws major tick at multiples of 5 cm with correct color', () async {
    const width = 120;
    const height = 100;
    const min = 0.0;
    const max = 10.0; // cm, so each 1 cm is 10 px vertically

    // Place selected indicator far outside to avoid overlay
    final painter = HeightScalePainter(
      selectedHeight: -999,
      minHeight: min,
      maxHeight: max,
      isCm: true,
      indicatorLength: 0,
    );

    final image = await _paintToImage(
      painter: painter,
      size: Size(width.toDouble(), height.toDouble()),
    );
    final rgba = await _readRgbaBytes(image);

    // Major ticks at 0, 5, 10 cm -> y = 100, 50, 0 respectively
    // Sample center of the stroke at x=20 for y=50
    final pixelMiddle = _rgbaAt(rgba, width, 20, 50);
    expect(pixelMiddle, equals(Color(0xFF757575).value)); // Colors.grey[600]

    // Sample a minor tick at 1 cm -> y = 90; color should be grey[400]
    final pixelMinor = _rgbaAt(rgba, width, 10, 90);
    expect(pixelMinor, equals(Color(0xFFBDBDBD).value));
  });
}
