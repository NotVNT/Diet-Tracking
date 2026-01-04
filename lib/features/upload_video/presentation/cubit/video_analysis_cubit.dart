import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/video_analysis_service.dart';
import 'video_analysis_state.dart';
import '../../../chat_bot_view_home/domain/repositories/user_repository.dart';
import '../../../chat_bot_view_home/data/repositories/user_repository_impl.dart';
import '../../../chat_bot_view_home/data/datasources/firestore_datasource.dart';
import '../../../../database/auth_service.dart';

class VideoAnalysisCubit extends Cubit<VideoAnalysisState> {
  final VideoAnalysisService _service;
  final UserRepository? _userRepository;

  VideoAnalysisCubit({
    VideoAnalysisService? service,
    UserRepository? userRepository,
  })  : _service = service ?? VideoAnalysisService(),
        _userRepository = userRepository ??
            UserRepositoryImpl(FirestoreDatasource(), AuthService()),
        super(VideoAnalysisInitial());

  Future<void> analyzeVideo(
    XFile video, {
    String? goal,
    String? allergy,
  }) async {
    emit(VideoAnalysisAnalyzing(video));

    try {
      // If not provided explicitly, try to fetch from user profile.
      String? effectiveGoal = goal;
      String? effectiveAllergy = allergy;

      if ((goal == null || goal.isEmpty || allergy == null || allergy.isEmpty) &&
          _userRepository != null) {
        try {
          final userData = await _userRepository.getCurrentUserData();
          effectiveGoal = (goal == null || goal.isEmpty)
              ? userData?.goal
              : goal;
          effectiveAllergy = (allergy == null || allergy.isEmpty)
              ? userData?.allergy
              : allergy;
        } catch (_) {
          // Silently continue with provided values if fetching fails
        }
      }

      final result = await _service.analyzeVideo(
        video.path,
        goal: effectiveGoal,
        allergy: effectiveAllergy,
      );
      emit(VideoAnalysisSuccess(video, result.recipe));
    } catch (e) {
      emit(VideoAnalysisFailure(e.toString(), video: video));
    }
  }

  void reset() {
    emit(VideoAnalysisInitial());
  }
}
