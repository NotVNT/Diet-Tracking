import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:diet_tracking_project/features/home_page/domain/entities/home_info.dart';
import 'package:diet_tracking_project/features/home_page/domain/usecases/get_home_info_usecase.dart';

import '../mocks.mocks.dart';

void main() {
  group('GetHomeInfoUseCase', () {
    test('delegates to repository.getHomeInfo', () async {
      final repo = MockHomeRepository();
      when(repo.getHomeInfo()).thenAnswer((_) async => HomeInfo(currentIndex: 2));

      final usecase = GetHomeInfoUseCase(repo);
      final result = await usecase();

      expect(result.currentIndex, 2);
      verify(repo.getHomeInfo()).called(1);
    });
  });
}
