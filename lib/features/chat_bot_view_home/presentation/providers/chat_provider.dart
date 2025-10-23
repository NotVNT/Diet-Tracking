import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/validate_message_usecase.dart';
import '../../domain/usecases/generate_food_suggestion_usecase.dart';
import '../../domain/usecases/create_new_chat_session_usecase.dart';
import '../../domain/repositories/chat_session_repository.dart';

/// Provider for chat functionality with session management
class ChatProvider extends ChangeNotifier {
  final SendMessageUseCase _sendMessageUseCase;
  final ValidateMessageUseCase _validateMessageUseCase;
  final GenerateFoodSuggestionUseCase _generateFoodSuggestionUseCase;
  final CreateNewChatSessionUseCase _createNewChatSessionUseCase;
  final ChatSessionRepository _chatSessionRepository;

  ChatProvider(
    this._sendMessageUseCase,
    this._validateMessageUseCase,
    this._generateFoodSuggestionUseCase,
    this._createNewChatSessionUseCase,
    this._chatSessionRepository,
  ) {
    _initializeChat();
  }

  // State
  ChatSessionEntity? _currentSession;
  bool _showOptions = false;
  bool _showFileInputs = false;
  bool _isLoading = false;

  // Getters
  List<ChatMessageEntity> get messages => _currentSession?.messages ?? [];
  bool get showOptions => _showOptions;
  bool get showFileInputs => _showFileInputs;
  bool get isLoading => _isLoading;
  ChatSessionEntity? get currentSession => _currentSession;
  String get currentSessionTitle => _currentSession?.title ?? 'Cuộc trò chuyện mới';

  void _initializeChat() async {
    // Try to load current session or create a new one
    final currentSessionId = await _chatSessionRepository.getCurrentSessionId();

    if (currentSessionId != null) {
      _currentSession = await _chatSessionRepository.getSessionById(currentSessionId);
    }

    // If no current session exists, create a new one
    _currentSession ??= await _createNewChatSessionUseCase.execute();

    notifyListeners();
  }

  /// Toggle options popup
  void toggleOptions() {
    _showOptions = !_showOptions;
    notifyListeners();
  }

  /// Hide options popup
  void hideOptions() {
    _showOptions = false;
    notifyListeners();
  }

  /// Show file inputs for food suggestion
  void showFoodSuggestionInputs() {
    _showFileInputs = true;
    _showOptions = false;
    notifyListeners();
  }

  /// Hide file inputs
  void hideFoodSuggestionInputs() {
    _showFileInputs = false;
    notifyListeners();
  }

  /// Send a regular message
  Future<String?> sendMessage(String message) async {
    // Validate message
    final validation = _validateMessageUseCase.execute(message);
    if (!validation.isValid) {
      return validation.error;
    }

    // Add user message
    _addMessage(ChatMessageEntity(
      text: validation.validMessage!,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _hideOptionsAndInputs();
    _setLoading(true);

    try {
      // Send message and get response
      final result = await _sendMessageUseCase.execute(validation.validMessage!);
      
      if (result.isSuccess) {
        _addMessage(ChatMessageEntity(
          text: result.response!,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        return null; // Success
      } else {
        _addMessage(ChatMessageEntity(
          text: result.error!,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        return result.error;
      }
    } catch (e) {
      final errorMessage = 'Lỗi không xác định: ${e.toString()}';
      _addMessage(ChatMessageEntity(
        text: errorMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      return errorMessage;
    } finally {
      _setLoading(false);
    }
  }

  /// Send food suggestion message
  Future<String?> sendFoodSuggestion({
    required String ingredients,
    required String budget,
    required String mealType,
  }) async {
    final prompt = _generateFoodSuggestionUseCase.execute(
      ingredients: ingredients,
      budget: budget,
      mealType: mealType,
    );

    return await sendMessage(prompt);
  }

  void _addMessage(ChatMessageEntity message) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.addMessage(message);
      // Update UI immediately
      notifyListeners();

      // Save to storage asynchronously without blocking UI
      _saveSessionAsync(_currentSession!);
    }
  }

  /// Save session asynchronously without blocking UI
  void _saveSessionAsync(ChatSessionEntity session) async {
    try {
      await _chatSessionRepository.saveSession(session);
    } catch (e) {
      // Handle save error silently or log it
      debugPrint('Error saving session: $e');
    }
  }

  /// Create a new chat session
  Future<void> createNewChatSession() async {
    _currentSession = await _createNewChatSessionUseCase.execute();
    notifyListeners();
  }

  void _hideOptionsAndInputs() {
    _showOptions = false;
    _showFileInputs = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
