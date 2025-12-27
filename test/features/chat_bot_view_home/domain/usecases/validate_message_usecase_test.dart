import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/validate_message_usecase.dart';

void main() {
  group('ValidateMessageUseCase', () {
    late ValidateMessageUseCase useCase;

    setUp(() {
      useCase = ValidateMessageUseCase();
    });

    test('returns failure when message is empty/whitespace', () {
      final result1 = useCase.execute('');
      final result2 = useCase.execute('   ');

      expect(result1.isValid, false);
      expect(result1.error, isNotNull);
      expect(result2.isValid, false);
      expect(result2.error, isNotNull);
    });

    test('returns failure when message contains line breaks', () {
      expect(useCase.execute('hello\nworld').isValid, false);
      expect(useCase.execute('hello\rworld').isValid, false);
      expect(useCase.execute('hello\r\nworld').isValid, false);
    });

    test('trims message and returns success', () {
      final result = useCase.execute('   xin chào   ');
      expect(result.isValid, true);
      expect(result.validMessage, 'xin chào');
      expect(result.error, isNull);
    });
  });
}
