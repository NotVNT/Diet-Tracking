import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:diet_tracking_project/features/chat_bot_view_home/presentation/providers/chat_provider.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/entities/chat_session_entity.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/send_message_usecase.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/validate_message_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';

import '../../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatProvider', () {
    late MockSendMessageUseCase sendMessageUseCase;
    late MockValidateMessageUseCase validateMessageUseCase;
    late MockGenerateFoodSuggestionUseCase generateFoodSuggestionUseCase;
    late MockBuildFoodScanAnalysisPromptUseCase buildFoodScanUseCase;
    late MockCreateNewChatSessionUseCase createNewChatSessionUseCase;
    late MockChatSessionRepository chatSessionRepository;

    late ChatProvider provider;

    setUp(() {
      sendMessageUseCase = MockSendMessageUseCase();
      validateMessageUseCase = MockValidateMessageUseCase();
      generateFoodSuggestionUseCase = MockGenerateFoodSuggestionUseCase();
      buildFoodScanUseCase = MockBuildFoodScanAnalysisPromptUseCase();
      createNewChatSessionUseCase = MockCreateNewChatSessionUseCase();
      chatSessionRepository = MockChatSessionRepository();

      provider = ChatProvider(
        sendMessageUseCase,
        validateMessageUseCase,
        generateFoodSuggestionUseCase,
        buildFoodScanUseCase,
        createNewChatSessionUseCase,
        chatSessionRepository,
      );

      when(chatSessionRepository.saveSession(any)).thenAnswer((_) async {});
      when(
        chatSessionRepository.setCurrentSessionId(any),
      ).thenAnswer((_) async {});
    });

    test(
      'createNewChatSession sets currentSession and marks as unsaved (no save yet)',
      () async {
        final session = ChatSessionEntity.createNew(id: 's1', title: 't1');
        when(
          createNewChatSessionUseCase.execute(),
        ).thenAnswer((_) async => session);

        await provider.createNewChatSession();

        expect(provider.currentSession, isNotNull);
        expect(provider.currentSession!.id, 's1');
        verifyNever(chatSessionRepository.saveSession(any));
      },
    );

    test(
      'sendMessage returns validation error and does not call send usecase',
      () async {
        final session = ChatSessionEntity.createNew(id: 's1');
        when(
          createNewChatSessionUseCase.execute(),
        ).thenAnswer((_) async => session);
        await provider.createNewChatSession();

        when(
          validateMessageUseCase.execute(any),
        ).thenReturn(ValidationResult.failure('bad'));

        final err = await provider.sendMessage('   ');

        expect(err, 'bad');
        verifyNever(sendMessageUseCase.execute(any));
        verifyNever(chatSessionRepository.saveSession(any));
      },
    );

    test(
      'sendMessage success: adds user+bot message, toggles loading, and saves session updates',
      () async {
        final session = ChatSessionEntity.createNew(id: 's1');
        when(
          createNewChatSessionUseCase.execute(),
        ).thenAnswer((_) async => session);
        await provider.createNewChatSession();

        when(
          validateMessageUseCase.execute(any),
        ).thenReturn(ValidationResult.success('hello'));

        final completer = Completer<SendMessageResult>();

        when(
          sendMessageUseCase.execute('hello'),
        ).thenAnswer((_) => completer.future);
        when(
          sendMessageUseCase.execute(
            any,
            extraContext: anyNamed('extraContext'),
          ),
        ).thenAnswer((_) async => SendMessageResult.success('unused'));

        final future = provider.sendMessage('hello');
        expect(provider.isLoading, true);

        completer.complete(SendMessageResult.success('hi there'));
        final err = await future;

        expect(err, isNull);
        expect(provider.isLoading, false);
        expect(provider.messages.where((m) => m.isUser).length, 1);
        expect(
          provider.messages.where((m) => !m.isUser).length,
          2,
        ); // welcome + bot

        // allow async void saves to run
        await Future<void>.delayed(Duration.zero);

        // user msg triggers first save (unsaved->saved), bot msg triggers second save
        verify(
          chatSessionRepository.saveSession(any),
        ).called(greaterThanOrEqualTo(2));
      },
    );

    test('sendMessage failure: adds bot error message', () async {
      final session = ChatSessionEntity.createNew(id: 's1');
      when(
        createNewChatSessionUseCase.execute(),
      ).thenAnswer((_) async => session);
      await provider.createNewChatSession();

      when(
        validateMessageUseCase.execute(any),
      ).thenReturn(ValidationResult.success('hello'));
      when(
        sendMessageUseCase.execute('hello'),
      ).thenAnswer((_) async => SendMessageResult.failure('server down'));

      final err = await provider.sendMessage('hello');

      expect(err, 'server down');
      expect(provider.messages.last.isUser, false);
      expect(provider.messages.last.text, 'server down');
    });

    test('sendMessage exception: adds user-friendly error message', () async {
      final session = ChatSessionEntity.createNew(id: 's1');
      when(
        createNewChatSessionUseCase.execute(),
      ).thenAnswer((_) async => session);
      await provider.createNewChatSession();

      when(
        validateMessageUseCase.execute(any),
      ).thenReturn(ValidationResult.success('hello'));
      when(sendMessageUseCase.execute('hello')).thenThrow(Exception('boom'));

      final err = await provider.sendMessage('hello');

      expect(
        err,
        'Không thể gửi tin nhắn. Vui lòng kiểm tra kết nối và thử lại.',
      );
      expect(provider.messages.last.isUser, false);
      expect(provider.messages.last.text, err);
    });

    test(
      'sendMessage: creating new chat cancels in-flight request from old session',
      () async {
        // Start with session s1
        final session1 = ChatSessionEntity.createNew(id: 's1');
        when(
          createNewChatSessionUseCase.execute(),
        ).thenAnswer((_) async => session1);
        await provider.createNewChatSession();

        when(
          validateMessageUseCase.execute(any),
        ).thenReturn(ValidationResult.success('hello'));

        // Make sendMessage async + controllable
        final completer = Completer<SendMessageResult>();
        when(
          sendMessageUseCase.execute('hello'),
        ).thenAnswer((_) => completer.future);
        when(
          sendMessageUseCase.execute(
            any,
            extraContext: anyNamed('extraContext'),
          ),
        ).thenAnswer((_) async => SendMessageResult.success('unused'));

        final pending = provider.sendMessage('hello');
        expect(provider.currentSession!.id, 's1');

        // While waiting, user creates a new session s2
        final session2 = ChatSessionEntity.createNew(id: 's2');
        when(
          createNewChatSessionUseCase.execute(),
        ).thenAnswer((_) async => session2);
        await provider.createNewChatSession();
        expect(provider.currentSession!.id, 's2');

        // Now the old response returns
        completer.complete(SendMessageResult.success('reply-from-s1'));
        final err = await pending;

        // Late response should not leak into s2 and should be cancelled (not saved)
        expect(err, isNull);
        expect(provider.currentSession!.id, 's2');
        expect(
          provider.messages.where((m) => m.text == 'reply-from-s1'),
          isEmpty,
        );

        // Ensure we never saved a bot reply for s1 after cancellation.
        final savedSessions = verify(
          chatSessionRepository.saveSession(captureAny),
        ).captured.whereType<ChatSessionEntity>().toList();
        final s1Saves = savedSessions.where((s) => s.id == 's1').toList();
        if (s1Saves.isNotEmpty) {
          final lastS1 = s1Saves.last;
          expect(
            lastS1.messages.any((m) => m.text == 'reply-from-s1'),
            isFalse,
          );
        }
      },
    );

    test(
      'initOrLoadRecentSession loads local current session id first',
      () async {
        final session = ChatSessionEntity.createNew(id: 's1');
        when(
          chatSessionRepository.getCurrentSessionId(),
        ).thenAnswer((_) async => 's1');
        when(
          chatSessionRepository.getMostRecentSessionIdFromCloud(),
        ).thenAnswer((_) async => 's2');
        when(
          chatSessionRepository.getSessionById('s1'),
        ).thenAnswer((_) async => session);

        await provider.initOrLoadRecentSession();

        expect(provider.currentSession, session);
        verify(chatSessionRepository.setCurrentSessionId('s1')).called(1);
      },
    );

    test(
      'initOrLoadRecentSession falls back to cloud id when local id is null',
      () async {
        final session = ChatSessionEntity.createNew(id: 's2');
        when(
          chatSessionRepository.getCurrentSessionId(),
        ).thenAnswer((_) async => null);
        when(
          chatSessionRepository.getMostRecentSessionIdFromCloud(),
        ).thenAnswer((_) async => 's2');
        when(
          chatSessionRepository.getSessionById('s2'),
        ).thenAnswer((_) async => session);

        await provider.initOrLoadRecentSession();

        expect(provider.currentSession, session);
        verify(chatSessionRepository.setCurrentSessionId('s2')).called(1);
      },
    );

    test(
      'initOrLoadRecentSession sets currentSession null when no ids found',
      () async {
        when(
          chatSessionRepository.getCurrentSessionId(),
        ).thenAnswer((_) async => null);
        when(
          chatSessionRepository.getMostRecentSessionIdFromCloud(),
        ).thenAnswer((_) async => null);

        await provider.initOrLoadRecentSession();

        expect(provider.currentSession, isNull);
      },
    );

    test(
      'sendFoodScanAnalysis uses prompt builder + passes extraContext to send usecase',
      () async {
        final session = ChatSessionEntity.createNew(id: 's1');
        when(
          createNewChatSessionUseCase.execute(),
        ).thenAnswer((_) async => session);
        await provider.createNewChatSession();

        final record = FoodRecordEntity(
          foodName: 'Táo',
          calories: 95,
          protein: 0.5,
          carbs: 25,
          fat: 0.3,
          barcode: '123',
          nutritionDetails: 'fiber',
          imagePath: 'img',
          date: DateTime.utc(2025, 1, 1),
          recordType: RecordType.barcode,
        );

        when(buildFoodScanUseCase.execute(any)).thenReturn('PROMPT');
        when(
          sendMessageUseCase.execute(
            'PROMPT',
            extraContext: anyNamed('extraContext'),
          ),
        ).thenAnswer((inv) async {
          final context =
              inv.namedArguments[#extraContext] as Map<String, dynamic>;
          expect(context, contains('food_scan'));
          return SendMessageResult.success('ok');
        });
        when(
          sendMessageUseCase.execute(any),
        ).thenAnswer((_) async => SendMessageResult.success('unused'));

        await provider.sendFoodScanAnalysis(record);

        // last message should be bot response
        expect(provider.messages.last.isUser, false);
        expect(provider.messages.last.text, 'ok');
      },
    );
  });
}
