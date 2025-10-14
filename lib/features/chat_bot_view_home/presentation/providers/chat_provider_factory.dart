import '../../data/datasources/firestore_datasource.dart';
import '../../data/datasources/gemini_api_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/validate_message_usecase.dart';
import '../../domain/usecases/generate_food_suggestion_usecase.dart';
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

    // Repositories
    final userRepository = UserRepositoryImpl(firestoreDatasource);
    final chatRepository = ChatRepositoryImpl(geminiApiDatasource);

    // Use cases
    final sendMessageUseCase = SendMessageUseCase(chatRepository, userRepository);
    final validateMessageUseCase = ValidateMessageUseCase();
    final generateFoodSuggestionUseCase = GenerateFoodSuggestionUseCase();

    // Create and store singleton instance
    _instance = ChatProvider(
      sendMessageUseCase,
      validateMessageUseCase,
      generateFoodSuggestionUseCase,
    );

    return _instance!;
  }

  /// Clear the singleton instance (useful for testing or logout)
  static void dispose() {
    _instance = null;
  }
}
