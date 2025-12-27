import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/send_message_usecase.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/entities/user_data_entity.dart';
import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';

import '../../mocks.mocks.dart';

void main() {
  group('SendMessageUseCase', () {
    late MockChatRepository chatRepository;
    late MockUserRepository userRepository;
    late SendMessageUseCase useCase;

    setUp(() {
      chatRepository = MockChatRepository();
      userRepository = MockUserRepository();
      useCase = SendMessageUseCase(chatRepository, userRepository);
    });

    test('returns failure when user is not authenticated', () async {
      when(userRepository.isUserAuthenticated()).thenAnswer((_) async => false);

      final result = await useCase.execute('hello');

      expect(result.isSuccess, false);
      expect(result.error, isNotNull);
      verifyNever(userRepository.getCurrentUserData());
      verifyNever(chatRepository.sendMessage(any, any));
    });

    test('returns failure when user data is null', () async {
      when(userRepository.isUserAuthenticated()).thenAnswer((_) async => true);
      when(userRepository.getCurrentUserData()).thenAnswer((_) async => null);

      final result = await useCase.execute('hello');

      expect(result.isSuccess, false);
      expect(result.error, isNotNull);
      verifyNever(chatRepository.sendMessage(any, any));
    });

    test('merges nutrition plan, food records, and extraContext into contextData', () async {
      when(userRepository.isUserAuthenticated()).thenAnswer((_) async => true);
      when(userRepository.getCurrentUserData()).thenAnswer(
        (_) async => const UserDataEntity(
          age: 25,
          height: 170,
          weight: 65,
          goalWeightKg: 60,
          disease: 'none',
          allergy: 'peanut',
          goal: 'lose_weight',
          gender: 'male',
        ),
      );
      final plan = NutritionCalculation(
        bmr: 1,
        tdee: 2,
        caloriesMax: 3,
        caloriesMin: 4,
        weightDifference: 5,
        totalCaloriesNeeded: 6,
        dailyCaloriesAdjustment: 7,
        targetCalories: 8,
        targetDays: 9,
        isHealthy: true,
      );
      when(userRepository.getNutritionPlan()).thenAnswer((_) async => plan);
      when(userRepository.getRecentFoodRecords()).thenAnswer(
        (_) async => [
          {'name': 'apple', 'calories': 95},
        ],
      );
      when(chatRepository.sendMessage(any, any)).thenAnswer((_) async => 'ok');

      final result = await useCase.execute(
        'hello',
        extraContext: {
          'food_scan': {'barcode': '123'},
        },
      );

      expect(result.isSuccess, true);

      final captured = verify(chatRepository.sendMessage('hello', captureAny))
          .captured
          .single as Map<String, dynamic>;

      expect(captured['age'], 25);
      expect(captured['height'], 170);
      expect(captured['weight'], 65);
      expect(captured['goalWeightKg'], 60);
      expect(captured['disease'], 'none');
      expect(captured['allergy'], 'peanut');
      expect(captured['goal'], 'lose_weight');
      expect(captured['gender'], 'male');

      expect(captured['nutrition_plan'], plan.toJson());
      expect(captured['food_records'], isA<List<Map<String, dynamic>>>());
      expect((captured['food_records'] as List).length, 1);
      expect(captured['food_scan'], {'barcode': '123'});
    });

    test('returns failure with user-friendly message when repository throws', () async {
      when(userRepository.isUserAuthenticated()).thenAnswer((_) async => true);
      when(userRepository.getCurrentUserData()).thenAnswer(
        (_) async => const UserDataEntity(
          age: 25,
          height: 170,
          weight: 65,
          disease: 'none',
          allergy: 'none',
          goal: 'maintain',
          gender: 'male',
        ),
      );
      when(userRepository.getNutritionPlan()).thenAnswer((_) async => null);
      when(userRepository.getRecentFoodRecords()).thenAnswer((_) async => []);
      when(chatRepository.sendMessage(any, any)).thenThrow(Exception('network'));

      final result = await useCase.execute('hello');

      expect(result.isSuccess, false);
      expect(
        result.error,
        'Không thể gửi tin nhắn. Vui lòng kiểm tra kết nối và thử lại.',
      );
    });
  });
}
