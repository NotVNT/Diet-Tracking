import 'package:flutter/material.dart';
import '../providers/chat_provider_factory.dart';
import '../providers/chat_provider.dart';
import '../widgets/messages_area.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_options_popup.dart';
import '../widgets/food_suggestion_inputs.dart';
import '../widgets/chat_settings_menu.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';

/// Main chat bot page with clean architecture
class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: l10n.chatBotDietAssistant,
        actions: [
          ChatSettingsMenu(
            onCreateNewChat: _onCreateNewChat,
            onChatHistory: _onChatHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          MessagesArea(messages: _chatProvider.messages),
          if (_chatProvider.showOptions)
            ChatOptionsPopup(onOptionSelected: _onOptionSelected),
          if (_chatProvider.showFileInputs)
            _buildFoodSuggestionInputs(_chatProvider),
          ChatInputArea(
            messageController: _messageController,
            onSendPressed: () => _onSendPressed(_chatProvider),
            onMessageSubmitted: (text) => _onMessageSubmitted(text, _chatProvider),
          ),
        ],
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
    final l10n = AppLocalizations.of(context)!;
    await _chatProvider.createNewChatSession();
    _showSnackBar(l10n.chatBotNewChatCreated);
  }

  /// Handles chat history action
  void _onChatHistory() {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Implement chat history view
    _showSnackBar(l10n.chatBotChatHistoryComingSoon);
  }


  /// Handles option selection
  void _onOptionSelected(String option) {
    final l10n = AppLocalizations.of(context)!;
    if (option == l10n.chatBotFoodSuggestion) {
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
    final l10n = AppLocalizations.of(context)!;
    final ingredients = _ingredientsController.text.trim();
    final budget = _budgetController.text.trim();
    final mealType = _mealTypeController.text.trim();

    if (ingredients.isEmpty || budget.isEmpty || mealType.isEmpty) {
      _showSnackBar(l10n.chatBotPleaseEnterAllInfo);
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
