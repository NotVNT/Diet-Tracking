import 'package:diet_tracking_project/features/upload_video/presentation/pages/video_processing_page.dart';
import 'package:diet_tracking_project/features/upload_video/presentation/cubit/video_analysis_cubit.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:diet_tracking_project/features/home_page/presentation/providers/home_provider.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

import '../../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockVideoAnalysisService mockService;
  late MockHomeProvider mockHomeProvider;
  late MockNotificationProvider mockNotificationProvider;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockService = MockVideoAnalysisService();
    mockHomeProvider = MockHomeProvider();
    mockNotificationProvider = MockNotificationProvider();
    mockUserRepository = MockUserRepository();

    // Mock permission handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'checkPermissionStatus') {
              return 1; // granted
            }
            if (methodCall.method == 'requestPermissions') {
              return {
                1: 1, // camera: granted
                2: 1, // microphone: granted
              };
            }
            return null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          null,
        );
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeProvider>.value(value: mockHomeProvider),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: mockNotificationProvider,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<VideoAnalysisCubit>(
          create: (_) => VideoAnalysisCubit(
            service: mockService,
            userRepository: mockUserRepository,
          ),
          child: const VideoProcessingView(),
        ),
      ),
    );
  }

  testWidgets('VideoProcessingPage shows upload button initially', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Upload Video'), findsOneWidget);
  });

  testWidgets('VideoProcessingPage shows analysis title', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Analysis from bot'), findsOneWidget);
  });
}
