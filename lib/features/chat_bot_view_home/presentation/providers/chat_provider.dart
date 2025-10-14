import 'package:flutter/material.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/validate_message_usecase.dart';
import '../../domain/usecases/generate_food_suggestion_usecase.dart';

/// Provider for chat functionality
class ChatProvider extends ChangeNotifier {
  final SendMessageUseCase _sendMessageUseCase;
  final ValidateMessageUseCase _validateMessageUseCase;
  final GenerateFoodSuggestionUseCase _generateFoodSuggestionUseCase;

  ChatProvider(
    this._sendMessageUseCase,
    this._validateMessageUseCase,
    this._generateFoodSuggestionUseCase,
  ) {
    _initializeChat();
  }

  // State
  final List<ChatMessageEntity> _messages = [];
  bool _showOptions = false;
  bool _showFileInputs = false;
  bool _isLoading = false;

  // Getters
  List<ChatMessageEntity> get messages => List.unmodifiable(_messages);
  bool get showOptions => _showOptions;
  bool get showFileInputs => _showFileInputs;
  bool get isLoading => _isLoading;

  void _initializeChat() {
    // Only add welcome message if no messages exist (first time initialization)
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessageEntity(
          text: 'Xin chào! Tôi có thể giúp gì cho bạn hôm nay?',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      );
    }
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
    _messages.add(message);
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
