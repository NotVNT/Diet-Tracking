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
  );

  // State
  ChatSessionEntity? _currentSession;
  bool _isLoading = false;
  bool _isNewSessionUnsaved = false; // Track if the session is temporary

  // Getters
  List<ChatMessageEntity> get messages => _currentSession?.messages ?? [];
  bool get isLoading => _isLoading;
  ChatSessionEntity? get currentSession => _currentSession;
  String get currentSessionTitle => _currentSession?.title ?? 'Cuộc trò chuyện mới';


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
    if (_currentSession == null) return;

    _currentSession = _currentSession!.addMessage(message);
    notifyListeners(); // Update UI immediately

    // If this is the first user message in a new session, save it and mark as saved.
    if (_isNewSessionUnsaved && message.isUser) {
      _isNewSessionUnsaved = false; // Mark as no longer temporary
      _saveSessionAsync(_currentSession!); // Persist for the first time
    }
    // Otherwise, if the session is already saved, continue saving updates.
    else if (!_isNewSessionUnsaved) {
      _saveSessionAsync(_currentSession!);
    }
    // If it's a new unsaved session and the message is from the bot, do nothing.
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
    _isNewSessionUnsaved = true; // Mark as temporary until first user message
    notifyListeners();
  }


  /// Load a specific chat session
  Future<void> loadChatSession(String sessionId) async {
    _setLoading(true);
    try {
      final session = await _chatSessionRepository.getSessionById(sessionId);
      if (session != null) {
        _currentSession = session;
        _isNewSessionUnsaved = false; // Loaded sessions are always saved
        await _chatSessionRepository.setCurrentSessionId(sessionId);
        notifyListeners(); // Notify UI to update with the new session
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
