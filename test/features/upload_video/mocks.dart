import 'package:diet_tracking_project/features/upload_video/services/video_analysis_service.dart';
import 'package:diet_tracking_project/features/home_page/presentation/providers/home_provider.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/cubit/record_cubit.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/cubit/record_state.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/repositories/user_repository.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/entities/user_data_entity.dart';
import 'package:mockito/mockito.dart';

class MockVideoAnalysisService extends Mock implements VideoAnalysisService {
  @override
  Future<VideoAnalysisResult> analyzeVideo(
    String videoPath, {
    String? goal,
    String? allergy,
  }) => super.noSuchMethod(
        Invocation.method(
          #analyzeVideo,
          [videoPath],
          {#goal: goal, #allergy: allergy},
        ),
        returnValue: Future<VideoAnalysisResult>.value(
          const VideoAnalysisResult(recipe: ''),
        ),
        returnValueForMissingStub: Future<VideoAnalysisResult>.value(
          const VideoAnalysisResult(recipe: ''),
        ),
      );
}

class MockUserRepository extends Mock implements UserRepository {
  @override
  Future<UserDataEntity?> getCurrentUserData() => super.noSuchMethod(
        Invocation.method(#getCurrentUserData, const []),
        returnValue: Future<UserDataEntity?>.value(null),
        returnValueForMissingStub: Future<UserDataEntity?>.value(null),
      );
}

class MockHomeProvider extends Mock implements HomeProvider {
  @override
  DateTime get selectedDate => DateTime.now();

  @override
  Future<void> setCurrentIndex(int? index) {
    return super.noSuchMethod(
      Invocation.method(#setCurrentIndex, [index]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

class MockNotificationProvider extends Mock implements NotificationProvider {
  @override
  int get unreadCount => super.noSuchMethod(
        Invocation.getter(#unreadCount),
        returnValue: 0,
        returnValueForMissingStub: 0,
      );
}

class MockRecordCubit extends Mock implements RecordCubit {
  @override
  RecordState get state => RecordInitial();
  
  @override
  Stream<RecordState> get stream => Stream.value(RecordInitial());

  @override
  Future<void> close() => Future.value();
}
