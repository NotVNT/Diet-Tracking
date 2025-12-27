import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/l10n/app_localizations_en.dart';
import 'package:diet_tracking_project/l10n/app_localizations_vi.dart';

const _arbEnPath = 'lib/l10n/app_en.arb';
const _arbViPath = 'lib/l10n/app_vi.arb';

const _l10nAbstractPath = 'lib/l10n/app_localizations.dart';
const _l10nEnDartPath = 'lib/l10n/app_localizations_en.dart';
const _l10nViDartPath = 'lib/l10n/app_localizations_vi.dart';

Map<String, dynamic> _loadArb(String path) {
  final raw = File(path).readAsStringSync();
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('ARB must decode to a JSON object', path);
  }
  return decoded;
}

String _loadText(String path) => File(path).readAsStringSync();

Set<String> _topLevelTranslationKeys(Map<String, dynamic> arb) {
  return arb.keys.where((k) => !k.startsWith('@')).toSet();
}

Set<String> _placeholdersUsedInValue(String value) {
  final matches = RegExp(r'\{([a-zA-Z_][a-zA-Z0-9_]*)\}').allMatches(value);
  return matches.map((m) => m.group(1)!).toSet();
}

Set<String> _placeholdersFromMetadata(Map<String, dynamic> arb, String key) {
  final metaKey = '@$key';
  final meta = arb[metaKey];
  if (meta is! Map) return <String>{};
  final placeholders = meta['placeholders'];
  if (placeholders is! Map) return <String>{};
  return placeholders.keys.cast<String>().toSet();
}

Set<String> _duplicateTopLevelKeysFromRaw(String raw) {
  final keys = <String>[];
  final matches = RegExp(r'^  "([^\"]+)"\s*:', multiLine: true)
      .allMatches(raw);
  for (final m in matches) {
    keys.add(m.group(1)!);
  }
  final seen = <String>{};
  final dups = <String>{};
  for (final k in keys) {
    if (!seen.add(k)) dups.add(k);
  }
  return dups;
}

bool _hasGetter(String fileText, String key) {
  return RegExp(r'\bString\s+get\s+' + RegExp.escape(key) + r'\b')
      .hasMatch(fileText);
}

bool _hasMethod(String fileText, String key) {
  return RegExp(r'\bString\s+' + RegExp.escape(key) + r'\s*\(')
      .hasMatch(fileText);
}

void main() {
  group('AppLocalizations core', () {
    test('supported locales include en and vi', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('vi')));
    });

    test('delegate supports en and vi', () {
      expect(AppLocalizations.delegate.isSupported(const Locale('en')), isTrue);
      expect(AppLocalizations.delegate.isSupported(const Locale('vi')), isTrue);
    });

    test('localizationsDelegates starts with AppLocalizations.delegate', () {
      expect(AppLocalizations.localizationsDelegates.first, AppLocalizations.delegate);
    });
  });

  group('ARB files', () {
    test('ARB JSON is valid', () {
      expect(() => _loadArb(_arbEnPath), returnsNormally);
      expect(() => _loadArb(_arbViPath), returnsNormally);
    });

    test('No duplicate top-level keys in ARB', () {
      final enRaw = _loadText(_arbEnPath);
      final viRaw = _loadText(_arbViPath);
      final enDups = _duplicateTopLevelKeysFromRaw(enRaw);
      final viDups = _duplicateTopLevelKeysFromRaw(viRaw);
      expect(enDups, isEmpty, reason: 'Duplicate keys in $_arbEnPath: ${enDups.join(', ')}');
      expect(viDups, isEmpty, reason: 'Duplicate keys in $_arbViPath: ${viDups.join(', ')}');
    });

    test('en/vi have identical translation key sets', () {
      final en = _loadArb(_arbEnPath);
      final vi = _loadArb(_arbViPath);
      final enKeys = _topLevelTranslationKeys(en);
      final viKeys = _topLevelTranslationKeys(vi);

      final onlyInEn = (enKeys.difference(viKeys)).toList()..sort();
      final onlyInVi = (viKeys.difference(enKeys)).toList()..sort();

      expect(onlyInEn, isEmpty, reason: 'Keys only in en: ${onlyInEn.join(', ')}');
      expect(onlyInVi, isEmpty, reason: 'Keys only in vi: ${onlyInVi.join(', ')}');
    });

    test('values are non-empty strings for all keys', () {
      final en = _loadArb(_arbEnPath);
      final vi = _loadArb(_arbViPath);
      final keys = _topLevelTranslationKeys(en).toList()..sort();

      for (final key in keys) {
        final enVal = en[key];
        final viVal = vi[key];

        expect(enVal, isA<String>(), reason: 'en[$key] must be a String');
        expect(viVal, isA<String>(), reason: 'vi[$key] must be a String');
        expect((enVal as String).trim(), isNotEmpty, reason: 'en[$key] is empty');
        expect((viVal as String).trim(), isNotEmpty, reason: 'vi[$key] is empty');
      }
    });

    test('placeholders are consistent and declared', () {
      final en = _loadArb(_arbEnPath);
      final vi = _loadArb(_arbViPath);
      final keys = _topLevelTranslationKeys(en).toList()..sort();

      for (final key in keys) {
        final enValue = en[key] as String;
        final viValue = vi[key] as String;
        final usedInEn = _placeholdersUsedInValue(enValue);
        final usedInVi = _placeholdersUsedInValue(viValue);

        // Required: placeholder usage must match between locales.
        expect(
          usedInEn,
          equals(usedInVi),
          reason: 'Placeholder usage differs between en/vi for $key. en=$usedInEn vi=$usedInVi',
        );

        if (usedInEn.isEmpty) {
          continue;
        }

        // Optional: if metadata exists, it must match usage.
        final enDeclared = _placeholdersFromMetadata(en, key);
        final viDeclared = _placeholdersFromMetadata(vi, key);

        if (enDeclared.isNotEmpty) {
          expect(enDeclared, equals(usedInEn), reason: 'en placeholders metadata mismatch for $key');
        }
        if (viDeclared.isNotEmpty) {
          expect(viDeclared, equals(usedInEn), reason: 'vi placeholders metadata mismatch for $key');
        }
      }
    });

    test('metadata keys (@key) always have a base key', () {
      final en = _loadArb(_arbEnPath);
      final vi = _loadArb(_arbViPath);

      Iterable<String> metaKeys(Map<String, dynamic> arb) =>
          arb.keys.where((k) => k.startsWith('@') && !k.startsWith('@@'));

      for (final metaKey in metaKeys(en)) {
        final base = metaKey.substring(1);
        expect(en.containsKey(base), isTrue, reason: '$_arbEnPath contains $metaKey but missing base key $base');
      }

      for (final metaKey in metaKeys(vi)) {
        final base = metaKey.substring(1);
        expect(vi.containsKey(base), isTrue, reason: '$_arbViPath contains $metaKey but missing base key $base');
      }
    });
  });

  group('Generated Dart files are in sync with ARB', () {
    test('all ARB keys exist in AppLocalizations abstract API', () {
      final en = _loadArb(_arbEnPath);
      final abstractText = _loadText(_l10nAbstractPath);
      final keys = _topLevelTranslationKeys(en).toList()..sort();

      for (final key in keys) {
        final placeholders = _placeholdersFromMetadata(en, key);
        final looksLikeMethod = placeholders.isNotEmpty || _placeholdersUsedInValue(en[key] as String).isNotEmpty;

        if (looksLikeMethod) {
          expect(_hasMethod(abstractText, key), isTrue, reason: 'Missing method signature for $key in $_l10nAbstractPath');
        } else {
          expect(_hasGetter(abstractText, key), isTrue, reason: 'Missing getter signature for $key in $_l10nAbstractPath');
        }
      }
    });

    test('all ARB keys are implemented in en/vi classes', () {
      final en = _loadArb(_arbEnPath);
      final enText = _loadText(_l10nEnDartPath);
      final viText = _loadText(_l10nViDartPath);
      final keys = _topLevelTranslationKeys(en).toList()..sort();

      for (final key in keys) {
        final placeholders = _placeholdersFromMetadata(en, key);
        final looksLikeMethod = placeholders.isNotEmpty || _placeholdersUsedInValue(en[key] as String).isNotEmpty;

        if (looksLikeMethod) {
          expect(_hasMethod(enText, key), isTrue, reason: 'Missing en method for $key in $_l10nEnDartPath');
          expect(_hasMethod(viText, key), isTrue, reason: 'Missing vi method for $key in $_l10nViDartPath');
        } else {
          expect(_hasGetter(enText, key), isTrue, reason: 'Missing en getter for $key in $_l10nEnDartPath');
          expect(_hasGetter(viText, key), isTrue, reason: 'Missing vi getter for $key in $_l10nViDartPath');
        }
      }
    });
  });

  group('Smoke test (delegates + widget tree)', () {
    testWidgets('loads English localization', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n?.appTitle ?? 'missing');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Diet Tracking'), findsOneWidget);
    });

    testWidgets('loads Vietnamese localization', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n?.appTitle ?? 'missing');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Theo dõi chế độ ăn'), findsOneWidget);
    });
  });

  group('Direct class sanity', () {
    test('a couple of known strings match expected', () {
      final en = AppLocalizationsEn('en');
      final vi = AppLocalizationsVi('vi');
      expect(en.appTitle, 'Diet Tracking');
      expect(vi.appTitle, 'Theo dõi chế độ ăn');
      expect(en.chatBotConfirmDeleteMessage('My Diet'), contains('My Diet'));
      expect(vi.chatBotConfirmDeleteMessage('Kế hoạch'), contains('Kế hoạch'));
    });
  });
}

