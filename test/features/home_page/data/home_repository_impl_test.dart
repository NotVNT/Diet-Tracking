import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/home_page/data/datasources/home_local_datasource.dart';
import 'package:diet_tracking_project/features/home_page/data/repositories/home_repository_impl.dart';

void main() {
  group('HomeRepositoryImpl', () {
    test('getHomeInfo returns HomeInfo with currentIndex from localDataSource', () async {
      final ds = HomeLocalDataSource();
      ds.setCurrentIndex(3);

      final repo = HomeRepositoryImpl(ds);
      final info = await repo.getHomeInfo();

      expect(info.currentIndex, 3);
    });

    test('updateCurrentIndex persists to localDataSource', () async {
      final ds = HomeLocalDataSource();
      final repo = HomeRepositoryImpl(ds);

      await repo.updateCurrentIndex(1);

      expect(ds.getCurrentIndex(), 1);
    });
  });
}
