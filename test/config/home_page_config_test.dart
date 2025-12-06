import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/config/home_page_config.dart';

void main() {
  group('HomePageConfig', () {
    group('isValidIndex', () {
      test('returns true for valid indices', () {
        expect(HomePageConfig.isValidIndex(HomePageConfig.homeIndex), true);
        expect(HomePageConfig.isValidIndex(HomePageConfig.recordIndex), true);
        expect(HomePageConfig.isValidIndex(HomePageConfig.chatBotIndex), true);
        expect(HomePageConfig.isValidIndex(HomePageConfig.profileIndex), true);
      });

      test('returns false for invalid indices', () {
        expect(HomePageConfig.isValidIndex(-1), false);
        expect(
          HomePageConfig.isValidIndex(HomePageConfig.profileIndex + 1),
          false,
        );
        expect(HomePageConfig.isValidIndex(999), false);
      });
    });
  });
}
