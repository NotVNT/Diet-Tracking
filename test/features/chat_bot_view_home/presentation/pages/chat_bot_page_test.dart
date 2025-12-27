import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:diet_tracking_project/features/chat_bot_view_home/presentation/pages/chat_bot_page.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/presentation/providers/chat_provider.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/presentation/widgets/chat_empty_state.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/presentation/widgets/messages_area.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/presentation/widgets/chat_input_area.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/entities/chat_session_entity.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/send_message_usecase.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/validate_message_usecase.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

import '../../mocks.mocks.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<NotificationProvider>(
        create: (_) => NotificationProvider(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

ChatProvider _buildProvider({
  required MockSendMessageUseCase sendMessageUseCase,
  required MockValidateMessageUseCase validateMessageUseCase,
  required MockGenerateFoodSuggestionUseCase generateFoodSuggestionUseCase,
  required MockBuildFoodScanAnalysisPromptUseCase buildFoodScanUseCase,
  required MockCreateNewChatSessionUseCase createNewChatSessionUseCase,
  required MockChatSessionRepository chatSessionRepository,
}) {
  return ChatProvider(
    sendMessageUseCase,
    validateMessageUseCase,
    generateFoodSuggestionUseCase,
    buildFoodScanUseCase,
    createNewChatSessionUseCase,
    chatSessionRepository,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatBotPage widget tests', () {
    late MockSendMessageUseCase sendMessageUseCase;
    late MockValidateMessageUseCase validateMessageUseCase;
    late MockGenerateFoodSuggestionUseCase generateFoodSuggestionUseCase;
    late MockBuildFoodScanAnalysisPromptUseCase buildFoodScanUseCase;
    late MockCreateNewChatSessionUseCase createNewChatSessionUseCase;
    late MockChatSessionRepository chatSessionRepository;

    setUp(() {
      sendMessageUseCase = MockSendMessageUseCase();
      validateMessageUseCase = MockValidateMessageUseCase();
      generateFoodSuggestionUseCase = MockGenerateFoodSuggestionUseCase();
      buildFoodScanUseCase = MockBuildFoodScanAnalysisPromptUseCase();
      createNewChatSessionUseCase = MockCreateNewChatSessionUseCase();
      chatSessionRepository = MockChatSessionRepository();

      when(chatSessionRepository.saveSession(any)).thenAnswer((_) async {});
      when(chatSessionRepository.setCurrentSessionId(any)).thenAnswer((_) async {});
    });

    testWidgets('shows loading then empty state when no session exists', (tester) async {
      when(chatSessionRepository.getCurrentSessionId()).thenAnswer((_) async => null);
      when(chatSessionRepository.getMostRecentSessionIdFromCloud()).thenAnswer((_) async => null);

      final provider = _buildProvider(
        sendMessageUseCase: sendMessageUseCase,
        validateMessageUseCase: validateMessageUseCase,
        generateFoodSuggestionUseCase: generateFoodSuggestionUseCase,
        buildFoodScanUseCase: buildFoodScanUseCase,
        createNewChatSessionUseCase: createNewChatSessionUseCase,
        chatSessionRepository: chatSessionRepository,
      );

      await tester.pumpWidget(_wrap(ChatBotPage(providerOverride: provider)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(ChatEmptyState), findsOneWidget);
    });

    testWidgets('tapping create new chat transitions to chat UI (messages + input)', (tester) async {
      when(chatSessionRepository.getCurrentSessionId()).thenAnswer((_) async => null);
      when(chatSessionRepository.getMostRecentSessionIdFromCloud()).thenAnswer((_) async => null);

      final session = ChatSessionEntity.createNew(id: 's1', title: 't1');
      when(createNewChatSessionUseCase.execute()).thenAnswer((_) async => session);

      final provider = _buildProvider(
        sendMessageUseCase: sendMessageUseCase,
        validateMessageUseCase: validateMessageUseCase,
        generateFoodSuggestionUseCase: generateFoodSuggestionUseCase,
        buildFoodScanUseCase: buildFoodScanUseCase,
        createNewChatSessionUseCase: createNewChatSessionUseCase,
        chatSessionRepository: chatSessionRepository,
      );

      await tester.pumpWidget(_wrap(ChatBotPage(providerOverride: provider)));
      await tester.pumpAndSettle();

      expect(find.byType(ChatEmptyState), findsOneWidget);

      final l10n = AppLocalizations.of(tester.element(find.byType(ChatEmptyState)))!;
      await tester.tap(find.text(l10n.chatBotCreateNewChat));
      await tester.pumpAndSettle();

      expect(find.byType(MessagesArea), findsOneWidget);
      expect(find.byType(ChatInputArea), findsOneWidget);
    });

    testWidgets('sending a message shows user text and bot response', (tester) async {
      final session = ChatSessionEntity.createNew(id: 's1', title: 't1');
      when(chatSessionRepository.getCurrentSessionId()).thenAnswer((_) async => 's1');
      when(chatSessionRepository.getSessionById('s1')).thenAnswer((_) async => session);

      when(validateMessageUseCase.execute('hello')).thenReturn(
        ValidationResult.success('hello'),
      );
      when(sendMessageUseCase.execute('hello')).thenAnswer(
        (_) async => SendMessageResult.success('bot reply'),
      );

      final provider = _buildProvider(
        sendMessageUseCase: sendMessageUseCase,
        validateMessageUseCase: validateMessageUseCase,
        generateFoodSuggestionUseCase: generateFoodSuggestionUseCase,
        buildFoodScanUseCase: buildFoodScanUseCase,
        createNewChatSessionUseCase: createNewChatSessionUseCase,
        chatSessionRepository: chatSessionRepository,
      );

      await tester.pumpWidget(_wrap(ChatBotPage(providerOverride: provider)));
      await tester.pumpAndSettle();

      // Enter text and send
      final l10n = AppLocalizations.of(tester.element(find.byType(ChatInputArea)))!;
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('bot reply'), findsOneWidget);

      // loading indicator should be off after completion
      expect(provider.isLoading, false);
      expect(find.text(l10n.chatBotEnterMessage), findsOneWidget);
    });
  });
}
