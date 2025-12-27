import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/widget/weight/bmi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Note: This test previously depended on `mockito`, but the project doesn't
// include it as a dev_dependency. To keep the test lightweight and avoid
// additional dependencies, we use small fakes with `noSuchMethod`.

// Mock classes for HttpClient
class MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();

  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _dummyFontData.length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(_dummyFontData).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _dummyFontData = Uint8List.fromList([
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x0d,
  0x00,
  0x01,
  0x00,
  0x08,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
]);

Widget _wrapWithApp(Widget child, {Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  HttpOverrides.runZoned(() {
    testWidgets('Shows placeholder when BMI is 0', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const BmiCard(bmi: 0, description: 'desc')),
      );

      expect(find.text('--'), findsOneWidget);
      expect(find.text('desc'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('Formats BMI with one decimal place', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const BmiCard(bmi: 23.456, description: 'Normal range')),
      );

      expect(find.text('23.5'), findsOneWidget);
      expect(find.text('Normal range'), findsOneWidget);
    });

    testWidgets('Displays localized title in English', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const BmiCard(bmi: 21.0, description: 'You have a normal weight.'),
          locale: const Locale('en'),
        ),
      );

      expect(find.text('Current BMI'), findsOneWidget);
    });

    testWidgets('Displays localized title in Vietnamese', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const BmiCard(bmi: 21.0, description: 'Bạn có cân nặng bình thường.'),
          locale: const Locale('vi'),
        ),
      );

      expect(find.text('Chỉ số BMI hiện tại'), findsOneWidget);
    });
  }, createHttpClient: (_) => MockHttpClient());
}
