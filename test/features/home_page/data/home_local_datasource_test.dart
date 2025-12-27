import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/home_page/data/datasources/home_local_datasource.dart';

void main() {
  group('HomeLocalDataSource', () {
    test('default currentIndex is 0', () {
      final ds = HomeLocalDataSource();
      expect(ds.getCurrentIndex(), 0);
    });

    test('setCurrentIndex updates value', () {
      final ds = HomeLocalDataSource();
      ds.setCurrentIndex(2);
      expect(ds.getCurrentIndex(), 2);
    });
  });
}
