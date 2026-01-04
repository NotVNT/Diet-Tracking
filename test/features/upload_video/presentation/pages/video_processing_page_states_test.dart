import 'package:diet_tracking_project/features/upload_video/presentation/cubit/video_analysis_cubit.dart';
import 'package:diet_tracking_project/features/upload_video/presentation/pages/video_processing_page.dart';
import 'package:diet_tracking_project/features/upload_video/services/video_analysis_service.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:provider/provider.dart';

import 'package:diet_tracking_project/features/home_page/presentation/providers/home_provider.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

import '../../mocks.dart';

import '../../helpers/fake_video_player_platform.dart';

class MockVideoAnalysisService extends Mock implements VideoAnalysisService {
  @override
  Future<VideoAnalysisResult> analyzeVideo(String videoPath) {
    return super.noSuchMethod(
      Invocation.method(#analyzeVideo, [videoPath]),
      returnValue: Future.value(const VideoAnalysisResult(recipe: '')),
      returnValueForMissingStub: Future.value(const VideoAnalysisResult(recipe: '')),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Ensure video_player is faked for any VideoPreviewWidget builds.
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  Widget wrap(Widget child) {
    final mockHomeProvider = MockHomeProvider();
    final mockNotificationProvider = MockNotificationProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeProvider>.value(value: mockHomeProvider),
        ChangeNotifierProvider<NotificationProvider>.value(value: mockNotificationProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('VideoProcessingView shows recipe text on success', (tester) async {
    final service = MockVideoAnalysisService();
    when(service.analyzeVideo('test.mp4')).thenAnswer(
      (_) async => const VideoAnalysisResult(recipe: 'My recipe'),
    );

    await tester.pumpWidget(wrap(VideoProcessingPage(service: service)));
    await tester.pump();

    final element = tester.element(find.byType(VideoProcessingView));
    final cubit = BlocProvider.of<VideoAnalysisCubit>(element);

    await cubit.analyzeVideo(XFile('test.mp4'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('My recipe'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('VideoProcessingView shows error message on failure', (tester) async {
    final service = MockVideoAnalysisService();
    when(service.analyzeVideo('test.mp4')).thenThrow(Exception('boom'));

    await tester.pumpWidget(wrap(VideoProcessingPage(service: service)));
    await tester.pump();

    final element = tester.element(find.byType(VideoProcessingView));
    final cubit = BlocProvider.of<VideoAnalysisCubit>(element);

    await cubit.analyzeVideo(XFile('test.mp4'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('boom'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
