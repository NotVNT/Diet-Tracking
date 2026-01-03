  import 'package:flutter/material.dart';
import '../providers/chat_provider_factory.dart';
  import '../providers/chat_provider.dart';
  import '../widgets/messages_area.dart';
  import '../widgets/chat_input_area.dart';
  import '../widgets/chat_options_popup.dart';
  import '../widgets/food_suggestion_inputs.dart';
  import '../widgets/chat_settings_menu.dart';
  import '../widgets/chat_empty_state.dart';
  import '../widgets/chat_history.dart';
  import '../../../../common/custom_app_bar.dart';
  import '../../../../l10n/app_localizations.dart';
  import '../../../../common/snackbar_helper.dart';
  import '../../../../services/user_avatar_service.dart';
  import '../../../../utils/bottom_sheet_utils.dart';

  import '../../../record_view_home/domain/entities/food_record_entity.dart';

  enum ChatUiPanel { none, options, foodSuggestion }


  /// Main chat bot page with clean architecture
class ChatBotPage extends StatefulWidget {
    final FoodRecordEntity? initialFoodAnalysis;
    final ChatProvider? providerOverride;
    const ChatBotPage({
      super.key,
      this.initialFoodAnalysis,
      this.providerOverride,
    });

    @override
    State<ChatBotPage> createState() => _ChatBotPageState();
  }

  class _ChatBotPageState extends State<ChatBotPage> {
    // Controllers
    final TextEditingController _messageController = TextEditingController();
    final TextEditingController _ingredientsController = TextEditingController();
    final TextEditingController _budgetController = TextEditingController();
    final TextEditingController _mealTypeController = TextEditingController();

    // UI state moved from provider
    ChatUiPanel _activePanel = ChatUiPanel.none;
    bool _isLoading = true; // Added for initial session loading

    // Chat provider instance
    late final ChatProvider _chatProvider;


    @override
    void initState() {
      super.initState();
      // Preload user avatar for chat bubbles (non-blocking)
      UserAvatarService.instance.ensureLoaded();
      _chatProvider = widget.providerOverride ?? ChatProviderFactory.create();
      _chatProvider.addListener(_onChatProviderChanged);

      _loadOrInitChatSession();

      // If a scanned food was passed in, trigger analysis after first frame
      if (widget.initialFoodAnalysis != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _activePanel = ChatUiPanel.none;
            });
          }
          _chatProvider.sendFoodScanAnalysis(widget.initialFoodAnalysis!);
        });
      }
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

    /// Loads the most recent chat session or creates a new one if none exist.
    Future<void> _loadOrInitChatSession() async {
      try {
        await _chatProvider.initOrLoadRecentSession();
      } catch (e) {
        // ignore: avoid_print
        print('Error initializing chat session: $e');
        if (mounted) {
          SnackBarHelper.showError(context, 'Could not initialize chat: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_chatProvider.currentSession == null
                  ? // Trạng thái trống khi chưa có phiên chat
                    ChatEmptyState(
                      onCreateNewChat: _onCreateNewChat,
                    )
                  : Column(
                      children: [
                        MessagesArea(
                          messages: _chatProvider.messages,
                          isLoading: _chatProvider.isLoading,
                        ),
                        if (_activePanel == ChatUiPanel.options)
                          ChatOptionsPopup(onOptionSelected: _onOptionSelected),
                        if (_activePanel == ChatUiPanel.foodSuggestion)
                          _buildFoodSuggestionInputs(_chatProvider),
                        ChatInputArea(
                          messageController: _messageController,
                          onSendPressed: () => _onSendPressed(_chatProvider),
                          onMessageSubmitted: (text) =>
                              _onMessageSubmitted(text, _chatProvider),
                        ),
                      ],
                    )),
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
      if (!mounted) return;
      SnackBarHelper.showSuccess(context, l10n.chatBotNewChatCreated);
    }

    /// Handles chat history action: show bottom sheet of last 5 sessions, allow delete
    void _onChatHistory() {
      showCustomBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        builder: (ctx) {
          return ChatHistory(
            onSelectSession: (id) async {
              await _chatProvider.loadChatSession(id);
            },
            onCreateNew: () async {
              await _chatProvider.createNewChatSession();
            },
            onDeletedSessionId: (deletedId) {
              _chatProvider.deleteLocalSessionById(deletedId);
            },
          );
        },
      );
    }

    /// Handles option selection
    void _onOptionSelected(String option) {
      final l10n = AppLocalizations.of(context)!;
      if (option == l10n.chatBotFoodSuggestion) {
        setState(() {
          _activePanel = ChatUiPanel.foodSuggestion;
        });
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
        SnackBarHelper.showWarning(context, l10n.chatBotPleaseEnterAllInfo);
        return;
      }

      final error = await chatProvider.sendFoodSuggestion(
        ingredients: ingredients,
        budget: budget,
        mealType: mealType,
      );

      if (error != null) {
        if (!mounted) return;
        SnackBarHelper.showError(context, error);
      } else {
        if (!mounted) return;
        SnackBarHelper.showSuccess(context, "Đã gửi yêu cầu gợi ý món ăn");
      }

      // Clear inputs and hide
      _ingredientsController.clear();
      _budgetController.clear();
      _mealTypeController.clear();
      setState(() {
        _activePanel = ChatUiPanel.none;
      });
    }

    /// Sends a regular message
    void _sendMessage(String text, ChatProvider chatProvider) async {
      if (text.trim().isEmpty) return;

      // Clear textfield immediately to prevent stuck text
      _messageController.clear();

      // Hide any auxiliary panels when sending a message
      if (_activePanel != ChatUiPanel.none) {
        setState(() {
          _activePanel = ChatUiPanel.none;
        });
      }

      final error = await chatProvider.sendMessage(text);
      if (error != null) {
        if (!mounted) return;
        SnackBarHelper.showError(context, error);
      }
    }
  }
