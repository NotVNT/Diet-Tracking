import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider_factory.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_options_popup.dart';
import '../widgets/food_suggestion_inputs.dart';
import '../widgets/chat_settings_menu.dart';

/// Main chat bot page with clean architecture
class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  static const Color _backgroundColor = Color(0xFF1A1A1A);

  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _mealTypeController = TextEditingController();

  // Chat provider instance
  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProviderFactory.create();
    _chatProvider.addListener(_onChatProviderChanged);
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onChatProviderChanged);
    _messageController.dispose();
    _ingredientsController.dispose();
    _budgetController.dispose();
    _mealTypeController.dispose();
    super.dispose();
  }

  void _onChatProviderChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildMessagesArea(_chatProvider),
          if (_chatProvider.showOptions)
            ChatOptionsPopup(onOptionSelected: _onOptionSelected),
          if (_chatProvider.showFileInputs)
            _buildFoodSuggestionInputs(_chatProvider),
          ChatInputArea(
            messageController: _messageController,
            showOptions: _chatProvider.showOptions,
            onToggleOptions: () => _chatProvider.toggleOptions(),
            onSendPressed: () => _onSendPressed(_chatProvider),
            onMessageSubmitted: (text) => _onMessageSubmitted(text, _chatProvider),
          ),
        ],
      ),
    );
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Text(
        'Diet Assistant',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        ChatSettingsMenu(
          onCreateNewChat: _onCreateNewChat,
          onChatHistory: _onChatHistory,
          onSettings: _onSettings,
        ),
      ],
    );
  }

  /// Builds the scrollable messages area
  Widget _buildMessagesArea(ChatProvider chatProvider) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chatProvider.messages.length,
        itemBuilder: (context, index) {
          final message = chatProvider.messages[index];
          return ChatMessageBubble(message: message);
        },
      ),
    );
  }

  /// Builds food suggestion inputs
  Widget _buildFoodSuggestionInputs(ChatProvider chatProvider) {
    return FoodSuggestionInputs(
      ingredientsController: _ingredientsController,
      budgetController: _budgetController,
      mealTypeController: _mealTypeController,
      onSubmit: () => _onFoodSuggestionSubmit(chatProvider),
    );
  }

  // Event Handlers

  /// Handles create new chat action
  void _onCreateNewChat() async {
    await _chatProvider.createNewChatSession();
    _showSnackBar('Đã tạo cuộc trò chuyện mới');
  }

  /// Handles chat history action
  void _onChatHistory() {
    // TODO: Implement chat history view
    _showSnackBar('Tính năng lịch sử chat sẽ được thêm sau');
  }

  /// Handles settings action
  void _onSettings() {
    // TODO: Implement settings page
    _showSnackBar('Tính năng cài đặt sẽ được thêm sau');
  }

  /// Handles option selection
  void _onOptionSelected(String option) {
    if (option == 'gợi ý món ăn') {
      _chatProvider.showFoodSuggestionInputs();
      return;
    }

    // Handle other options if needed
  }

  /// Handles message submission from text field
  void _onMessageSubmitted(String text, ChatProvider chatProvider) {
    _sendMessage(text, chatProvider);
  }

  /// Handles send button press
  void _onSendPressed(ChatProvider chatProvider) {
    final text = _messageController.text;
    _sendMessage(text, chatProvider);
  }

  /// Handles food suggestion submission
  void _onFoodSuggestionSubmit(ChatProvider chatProvider) async {
    final ingredients = _ingredientsController.text.trim();
    final budget = _budgetController.text.trim();
    final mealType = _mealTypeController.text.trim();

    if (ingredients.isEmpty || budget.isEmpty || mealType.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin');
      return;
    }

    final error = await chatProvider.sendFoodSuggestion(
      ingredients: ingredients,
      budget: budget,
      mealType: mealType,
    );

    if (error != null) {
      _showSnackBar(error);
    }

    // Clear inputs and hide
    _ingredientsController.clear();
    _budgetController.clear();
    _mealTypeController.clear();
    chatProvider.hideFoodSuggestionInputs();
  }

  /// Sends a regular message
  void _sendMessage(String text, ChatProvider chatProvider) async {
    if (text.trim().isEmpty) return;

    // Clear textfield immediately to prevent stuck text
    _messageController.clear();

    final error = await chatProvider.sendMessage(text);
    if (error != null) {
      _showSnackBar(error);
    }
  }

  /// Shows snackbar with message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
