import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/l10n/app_localizations_en.dart';
import 'package:diet_tracking_project/l10n/app_localizations_vi.dart';

void main() {
  group('AppLocalizations core', () {
    test('supported locales include en and vi', () {
      final locales = AppLocalizations.supportedLocales;
      expect(locales.contains(const Locale('en')), true);
      expect(locales.contains(const Locale('vi')), true);
    });

    test('delegate supports en and vi', () {
      expect(AppLocalizations.delegate.isSupported(const Locale('en')), true);
      expect(AppLocalizations.delegate.isSupported(const Locale('vi')), true);
    });

    test('localizationsDelegates starts with AppLocalizations.delegate', () {
      expect(AppLocalizations.localizationsDelegates.first, AppLocalizations.delegate);
    });
  });

  group('English strings', () {
    test('basic keys', () {
      final en = AppLocalizationsEn('en');
      expect(en.appTitle, 'Diet Tracking');
      expect(en.apply, 'Apply');
      expect(en.success, 'Success');
      expect(en.cancel, 'Cancel');
      expect(en.delete, 'Delete');
      expect(en.snackbarSuccessTitle, 'Success');
      expect(en.accountUsesProviderMessage('Google'), contains('Google'));
    });
  });

  group('Vietnamese strings', () {
    test('basic keys', () {
      final vi = AppLocalizationsVi('vi');
      expect(vi.appTitle, 'Theo dõi chế độ ăn');
      expect(vi.apply, 'Áp dụng');
      expect(vi.success, 'Thành công');
      expect(vi.cancel, 'Hủy');
      expect(vi.delete, 'Xóa');
      expect(vi.snackbarSuccessTitle, 'Thành công');
      // For dynamic message
      expect(vi.deleteMealMessage('Cơm'), contains('Cơm'));
    });
  });
}

