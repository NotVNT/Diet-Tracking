import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/validate_message_usecase.dart';
import '../../domain/usecases/generate_food_suggestion_usecase.dart';
import '../../domain/usecases/create_new_chat_session_usecase.dart';
import '../../domain/repositories/chat_session_repository.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';

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

  /// Analyze a scanned food item for personal suitability using user's profile
  Future<void> sendFoodScanAnalysis(FoodRecordEntity record) async {
    // Short user-facing message
    final userMsg = 'Phân tích mức độ phù hợp của sản phẩm: ${record.foodName} (${record.calories.toStringAsFixed(0)} kcal)';
    _addMessage(ChatMessageEntity(
      text: userMsg,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _hideOptionsAndInputs();
    _setLoading(true);

    try {
      final prompt = _buildFoodScanAnalysisPrompt(record);
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

  String _buildFoodScanAnalysisPrompt(FoodRecordEntity r) {
    final buf = StringBuffer();
    buf.writeln('Bạn là chuyên gia dinh dưỡng cá nhân.');
    buf.writeln('Nhiệm vụ: đánh giá mức độ phù hợp của sản phẩm thực phẩm dưới đây với hồ sơ sức khỏe và mục tiêu của người dùng.');
    buf.writeln('Hãy trả lời NGẮN GỌN và rõ ràng theo cấu trúc:');
    buf.writeln('- Kết luận: Safe to eat | Use with caution | Not recommended');
    buf.writeln('- Lý do chính (gạch đầu dòng)');
    buf.writeln('- Lưu ý dị ứng/kiêng kỵ nếu có');
    buf.writeln('- Mẹo thay thế lành mạnh (nếu cần)');
    buf.writeln('');
    buf.writeln('Thông tin sản phẩm đã quét:');
    buf.writeln('• Tên: ${r.foodName}');
    buf.writeln('• Calories: ${r.calories.toStringAsFixed(0)} kcal');
    if (r.protein != null) buf.writeln('• Protein: ${r.protein!.toStringAsFixed(0)} g');
    if (r.carbs != null) buf.writeln('• Carbs: ${r.carbs!.toStringAsFixed(0)} g');
    if (r.fat != null) buf.writeln('• Fat: ${r.fat!.toStringAsFixed(0)} g');
    if (r.barcode != null && r.barcode!.trim().isNotEmpty) buf.writeln('• Barcode: ${r.barcode}');
    if (r.nutritionDetails != null && r.nutritionDetails!.trim().isNotEmpty) {
      buf.writeln('• Thông tin thành phần/dinh dưỡng thêm:');
      buf.writeln(r.nutritionDetails);
    }
    buf.writeln('');
    buf.writeln('Dựa trên hồ sơ người dùng và kế hoạch dinh dưỡng (được cung cấp trong ngữ cảnh hệ thống), hãy đưa ra đánh giá cá nhân hóa.');
    buf.writeln('Nếu có nguy cơ dị ứng (ví dụ chứa các thành phần thường gây dị ứng như đậu phộng, sữa, gluten, hải sản, trứng, đậu nành, hạt tree nuts, v.v.) hãy nêu rõ.');
    buf.writeln('Nếu người dùng có bệnh nền (tiểu đường, tăng huyết áp, rối loạn mỡ máu, thận, dạ dày...) hãy cân nhắc đường, natri, chất béo bão hòa, chất xơ...');
    buf.writeln('Hãy thật súc tích (tối đa ~120-160 từ).');
    return buf.toString();
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
