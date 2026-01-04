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
  // Tracks concurrent async operations per session so loading UI is scoped.
  final Map<String, int> _busyCountBySession = {};
  // In-flight request generation per session. When user starts/switches chat,
  // we bump generation of the previous session so any late response for the
  // previous generation is ignored. This does NOT block future sends.
  final Map<String, int> _requestGenerationBySession = {};
  bool _isNewSessionUnsaved = false; // Track if the session is temporary

  // Getters
  List<ChatMessageEntity> get messages => _currentSession?.messages ?? [];
  bool get isLoading {
    final id = _currentSession?.id;
    if (id == null) return false;
    return (_busyCountBySession[id] ?? 0) > 0;
  }

  /// Mark a session as busy/idle (to show the in-chat typing/analyzing bubble).
  ///
  /// This is used for non-chat API calls (e.g. video analysis) that should still
  /// show the same "Đang phân tích…" indicator.
  void setSessionBusy(String sessionId, bool busy) {
    _setLoading(busy, sessionId);
  }

  ChatSessionEntity? get currentSession => _currentSession;
  String get currentSessionTitle =>
      _currentSession?.title ?? 'Cuộc trò chuyện mới';

  int _getGeneration(String sessionId) =>
      _requestGenerationBySession[sessionId] ?? 0;

  void _bumpGeneration(String sessionId) {
    _requestGenerationBySession[sessionId] = _getGeneration(sessionId) + 1;
  }

  /// Send a regular message
  Future<String?> sendMessage(String message) async {
    // Capture which session this message belongs to.
    // If user switches/creates a new session while request is in-flight,
    // we must not append the bot response to the new session.
    final ChatSessionEntity? originSession = _currentSession;
    final String? originSessionId = originSession?.id;

    // Validate message
    final validation = _validateMessageUseCase.execute(message);
    if (!validation.isValid) {
      return validation.error;
    }

    // If there is no active session, we can't send.
    if (originSessionId == null || originSession == null) {
      return 'Chưa có cuộc trò chuyện nào được chọn.';
    }

    // Add user message
    _addMessage(
      ChatMessageEntity(
        text: validation.validMessage!,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    final int originGeneration = _getGeneration(originSessionId);

    _setLoading(true, originSessionId);

    try {
      // Send message and get response
      final result = await _sendMessageUseCase.execute(
        validation.validMessage!,
      );

      // If user created/switched chat while waiting, ignore.
      if (_getGeneration(originSessionId) != originGeneration) {
        return null;
      }

      if (result.isSuccess) {
        await _appendBotMessageToSession(originSessionId, result.response!);
        return null; // Success
      } else {
        await _appendBotMessageToSession(originSessionId, result.error!);
        return result.error;
      }
    } catch (e) {
      // Hide technical error details from users
      const errorMessage =
          'Không thể gửi tin nhắn. Vui lòng kiểm tra kết nối và thử lại.';
      if (_getGeneration(originSessionId) == originGeneration) {
        await _appendBotMessageToSession(originSessionId, errorMessage);
      }
      return errorMessage;
    } finally {
      _setLoading(false, originSessionId);
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
    final ChatSessionEntity? originSession = _currentSession;
    final String? originSessionId = originSession?.id;
    if (originSessionId == null || originSession == null) return;

    // Short user-facing message
    final userMsg =
        'Phân tích mức độ phù hợp của sản phẩm: ${record.foodName} (${record.calories.toStringAsFixed(0)} kcal)';
    _addMessage(
      ChatMessageEntity(text: userMsg, isUser: true, timestamp: DateTime.now()),
    );

    final int originGeneration = _getGeneration(originSessionId);

    _setLoading(true, originSessionId);

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
        },
      };
      final result = await _sendMessageUseCase.execute(
        prompt,
        extraContext: extraContext,
      );

      // If user created/switched chat while waiting, ignore.
      if (_getGeneration(originSessionId) != originGeneration) {
        return;
      }
      if (result.isSuccess) {
        await _appendBotMessageToSession(originSessionId, result.response!);
      } else {
        await _appendBotMessageToSession(
          originSessionId,
          result.error ?? 'Không thể phân tích sản phẩm. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      if (_getGeneration(originSessionId) == originGeneration) {
        await _appendBotMessageToSession(
          originSessionId,
          'Không thể phân tích sản phẩm. Vui lòng thử lại.',
        );
      }
    } finally {
      _setLoading(false, originSessionId);
    }
  }

  /// Append a bot message to a specific session id.
  ///
  /// This prevents bot replies from leaking into the currently visible session
  /// when the user switches chats while the request is still in-flight.
  Future<void> _appendBotMessageToSession(String sessionId, String text) async {
    try {
      final message = ChatMessageEntity(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Load latest snapshot of the session and persist update.
      // If the session is currently open, update in-memory state too.
      ChatSessionEntity? session;
      if (_currentSession?.id == sessionId) {
        session = _currentSession;
      } else {
        session = await _chatSessionRepository.getSessionById(sessionId);
      }

      if (session == null) return;

      final updated = session.addMessage(message);
      await _chatSessionRepository.saveSession(updated);

      if (_currentSession?.id == sessionId) {
        _currentSession = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error appending message to session $sessionId: $e');
    }
  }

  /// Append a local bot message (no API call) to a specific session.
  ///
  /// Useful for features where the response comes from a non-chat endpoint
  /// (e.g. video->recipe) but we still want to store and display it like a bot reply.
  Future<void> appendLocalBotMessageForSession({
    required String sessionId,
    required String text,
  }) async {
    await _appendBotMessageToSession(sessionId, text);
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
  }

  void _saveSessionAsync(ChatSessionEntity session) async {
    try {
      await _chatSessionRepository.saveSession(session);
    } catch (e) {
      // Handle save error silently or log it
      debugPrint('Error saving session: $e');
    }
  }

  Future<void> createNewChatSession() async {
    final previousId = _currentSession?.id;
    _currentSession = await _createNewChatSessionUseCase.execute();
    _isNewSessionUnsaved = true;
    if (previousId != null) {
      _cancelSession(previousId);
    }
    // Ensure new session can send messages immediately (not affected by old cancels)
    final newId = _currentSession?.id;
    if (newId != null) {
      _requestGenerationBySession.putIfAbsent(newId, () => 0);
    }
    notifyListeners();
  }

  Future<void> loadChatSession(String sessionId) async {
    final previousId = _currentSession?.id;
    if (previousId != null && previousId != sessionId) {
      _cancelSession(previousId);
    }
    _setLoading(true, sessionId);
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
      _setLoading(false, sessionId);
    }
  }

  Future<void> initOrLoadRecentSession() async {
    const initKey = '__init__';
    _setLoading(true, initKey);
    try {
      // Try local current session id first
      String? sessionId = await _chatSessionRepository.getCurrentSessionId();
      sessionId ??= await _chatSessionRepository
          .getMostRecentSessionIdFromCloud();

      if (sessionId != null) {
        final session = await _chatSessionRepository.getSessionById(sessionId);
        if (session != null) {
          _currentSession = session;
          _isNewSessionUnsaved = false;
          await _chatSessionRepository.setCurrentSessionId(sessionId);
          notifyListeners();
        } else {
          _currentSession = null;
          _isNewSessionUnsaved = false;
          notifyListeners();
        }
      } else {
        _currentSession = null;
        _isNewSessionUnsaved = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing chat provider: $e');
    } finally {
      _setLoading(false, initKey);
    }
  }

  Future<void> deleteLocalSessionById(String sessionId) async {
    try {
      await _chatSessionRepository.deleteSession(sessionId);
      if (_currentSession?.id == sessionId) {
        clearCurrentSession();
      }
    } catch (e) {
      debugPrint('Error deleting local session: $e');
    }
  }

  void _setLoading(bool loading, String sessionId) {
    final prev = _busyCountBySession[sessionId] ?? 0;
    int next = prev;
    if (loading) {
      next = prev + 1;
    } else {
      next = prev > 0 ? prev - 1 : 0;
    }

    if (next == 0) {
      _busyCountBySession.remove(sessionId);
    } else {
      _busyCountBySession[sessionId] = next;
    }

    // Notify only if this session is currently displayed (prevents loading bubble
    // from following into another chat).
    if (_currentSession?.id == sessionId || sessionId == '__init__') {
      if (prev != next) notifyListeners();
    }
  }

  void _cancelSession(String sessionId) {
    // Cancel only current in-flight requests for this session.
    _bumpGeneration(sessionId);
    _busyCountBySession.remove(sessionId);
  }

  void clearCurrentSession() {
    _currentSession = null;
    _isNewSessionUnsaved = false;
    notifyListeners();
  }
}
