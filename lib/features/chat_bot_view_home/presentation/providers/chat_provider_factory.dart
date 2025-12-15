import '../../data/datasources/firestore_datasource.dart';
import '../../../../services/chat_sessions_service.dart';

import '../../data/datasources/chatbot_endpoint_datasource.dart';
import '../../data/datasources/chat_session_local_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../../database/auth_service.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/chat_session_repository_impl.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/validate_message_usecase.dart';
import '../../domain/usecases/generate_food_suggestion_usecase.dart';
import '../../domain/usecases/food_scan_analysis_usecase.dart';
import '../../domain/usecases/create_new_chat_session_usecase.dart';
import 'chat_provider.dart';

/// Factory for creating ChatProvider with all dependencies
/// Uses singleton pattern to persist chat state across tab switches
class ChatProviderFactory {
  static ChatProvider? _instance;

  static ChatProvider create() {
    if (_instance != null) {
      return _instance!;
    }

    // Data sources
    final firestoreDatasource = FirestoreDatasource();
    final geminiApiDatasource = GeminiApiDatasource();
    final chatSessionLocalDataSource = InMemoryChatSessionLocalDataSource();

    // Repositories
    final authService = AuthService(); // Khởi tạo AuthService
    final userRepository = UserRepositoryImpl(firestoreDatasource, authService);
    final chatRepository = ChatRepositoryImpl(geminiApiDatasource);
    final cloudChatService = ChatSessionsService();
    final chatSessionRepository = ChatSessionRepositoryImpl(
      chatSessionLocalDataSource,
      cloudChatService,
    );

    // Use cases
    final sendMessageUseCase = SendMessageUseCase(
      chatRepository,
      userRepository,
    );
    final validateMessageUseCase = ValidateMessageUseCase();
    final generateFoodSuggestionUseCase = GenerateFoodSuggestionUseCase();
    final buildFoodScanAnalysisPromptUseCase = BuildFoodScanAnalysisPromptUseCase();
    final createNewChatSessionUseCase = CreateNewChatSessionUseCase(
      chatSessionRepository,
    );

    // Create and store singleton instance
    _instance = ChatProvider(
      sendMessageUseCase,
      validateMessageUseCase,
      generateFoodSuggestionUseCase,
      buildFoodScanAnalysisPromptUseCase,
      createNewChatSessionUseCase,
      chatSessionRepository,
    );

    return _instance!;
  }

  /// Clear the singleton instance (useful for testing or logout)
  static void dispose() {
    _instance = null;
  }
}
