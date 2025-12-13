import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/validate_message_usecase.dart';
import '../../domain/usecases/generate_food_suggestion_usecase.dart';
import '../../domain/usecases/food_scan_analysis_usecase.dart';
import '../../domain/usecases/create_new_chat_session_usecase.dart';
import '../../domain/repositories/chat_session_repository.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';

/// Provider for chat functionality with session management
class ChatProvider extends ChangeNotifier {
  final SendMessageUseCase _sendMessageUseCase;
  final ValidateMessageUseCase _validateMessageUseCase;
  final GenerateFoodSuggestionUseCase _generateFoodSuggestionUseCase;
  final BuildFoodScanAnalysisPromptUseCase _buildFoodScanAnalysisPromptUseCase;
  final CreateNewChatSessionUseCase _createNewChatSessionUseCase;
  final ChatSessionRepository _chatSessionRepository;

  ChatProvider(
    this._sendMessageUseCase,
    this._validateMessageUseCase,
    this._generateFoodSuggestionUseCase,
    this._buildFoodScanAnalysisPromptUseCase,
    this._createNewChatSessionUseCase,
    this._chatSessionRepository,
  ) {
    _initializeChat();
  }

  // State
  ChatSessionEntity? _currentSession;
  bool _isLoading = false;

  // Getters
  List<ChatMessageEntity> get messages => _currentSession?.messages ?? [];
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

    // Repository handles any background sync to cloud after local persistence
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

  /// Analyze a scanned food item for personal suitability using user's profile
  Future<void> sendFoodScanAnalysis(FoodRecordEntity record) async {
    // Short user-facing message
    final userMsg = 'Phân tích mức độ phù hợp của sản phẩm: ${record.foodName} (${record.calories.toStringAsFixed(0)} kcal)';
    _addMessage(ChatMessageEntity(
      text: userMsg,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _setLoading(true);

    try {
      final prompt = _buildFoodScanAnalysisPromptUseCase.execute(record);
      final extraContext = {
        'food_scan': {
          'name': record.foodName,
          'calories': record.calories,
          'protein': record.protein,
          'carbs': record.carbs,
          'fat': record.fat,
          'barcode': record.barcode,
          'nutrition_details': record.nutritionDetails,
          'record_type': record.recordType.name,
          'image_url': record.imagePath,
          'timestamp': record.date.toIso8601String(),
        }
      };
      final result = await _sendMessageUseCase.execute(
        prompt,
        extraContext: extraContext,
      );
      if (result.isSuccess) {
        _addMessage(ChatMessageEntity(
          text: result.response!,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        _addMessage(ChatMessageEntity(
          text: result.error ?? 'Không thể phân tích sản phẩm. Vui lòng thử lại.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      _addMessage(ChatMessageEntity(
        text: 'Đã xảy ra lỗi khi phân tích: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _setLoading(false);
    }
  }


  void _addMessage(ChatMessageEntity message) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.addMessage(message);
      // Update UI immediately
      notifyListeners();

      // Save to storage asynchronously without blocking UI
      _saveSessionAsync(_currentSession!);
      // Cloud sync (if any) is handled inside repository layer
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
