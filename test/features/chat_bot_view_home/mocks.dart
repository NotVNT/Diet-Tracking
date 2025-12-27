import 'package:mockito/annotations.dart';

import 'package:diet_tracking_project/features/chat_bot_view_home/domain/repositories/chat_repository.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/repositories/chat_session_repository.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/repositories/user_repository.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/create_new_chat_session_usecase.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/food_scan_analysis_usecase.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/generate_food_suggestion_usecase.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/send_message_usecase.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/validate_message_usecase.dart';

@GenerateMocks([
  ChatRepository,
  UserRepository,
  ChatSessionRepository,
  SendMessageUseCase,
  ValidateMessageUseCase,
  GenerateFoodSuggestionUseCase,
  BuildFoodScanAnalysisPromptUseCase,
  CreateNewChatSessionUseCase,
])
void main() {}
