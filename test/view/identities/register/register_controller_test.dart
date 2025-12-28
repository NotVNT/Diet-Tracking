import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/register/register_controller.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:diet_tracking_project/database/data_migration_service.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/database/exceptions.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Stub implementation của AuthService cho testing
class _AuthStub extends AuthService {
  MockUser? userToReturn;
  Exception? signUpException;
  bool? emailInUseToReturn;
  bool? firebaseConnectionToReturn;

  _AuthStub()
    : super(auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());

  @override
  Future<MockUser?> signUpWithOnboardingData({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? goalWeightKg,
    int? age,
    String? goal,
    List<String>? allergies,
  }) async {
    if (signUpException != null) throw signUpException!;
    return userToReturn;
  }

  @override
  Future<bool> isEmailAlreadyInUse(String email) async {
    return emailInUseToReturn ?? false;
  }

  @override
  Future<bool> testFirebaseConnection() async {
    return firebaseConnectionToReturn ?? true;
  }

  @override
  Future<void> sendEmailVerification() async {
    // Mock implementation
  }
}

/// Stub implementation của DataMigrationService cho testing
class _DataMigrationStub extends DataMigrationService {
  Exception? syncException;

  _DataMigrationStub({required AuthService authService})
      : super(local: LocalStorageService(), auth: authService);

  @override
  Future<void> syncGuestToUser(String uid) async {
    if (syncException != null) throw syncException!;
  }
}

void main() {
  group('RegisterController - Validation Tests', () {
    late RegisterController controller;

    setUp(() {
      controller = RegisterController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('validateFullName', () {
      test('trả về null khi họ và tên hợp lệ', () {
        final result = controller.validateFullName('John Doe');
        expect(result, isNull);
      });

      test('trả về error code khi họ và tên trống', () {
        final result = controller.validateFullName('');
        expect(result, RegisterErrorCode.emptyFullName);
      });

      test('trả về error code khi họ và tên chỉ có khoảng trắng', () {
        final result = controller.validateFullName('   ');
        expect(result, RegisterErrorCode.emptyFullName);
      });

      test('trả về error code khi họ và tên là null', () {
        final result = controller.validateFullName(null);
        expect(result, RegisterErrorCode.emptyFullName);
      });
    });

    group('validatePhone', () {
      test('trả về null khi số điện thoại hợp lệ', () {
        final result = controller.validatePhone('0123456789');
        expect(result, isNull);
      });

      test('trả về error code khi số điện thoại trống', () {
        final result = controller.validatePhone('');
        expect(result, RegisterErrorCode.emptyPhone);
      });

      test('trả về error code khi số điện thoại chỉ có khoảng trắng', () {
        final result = controller.validatePhone('   ');
        expect(result, RegisterErrorCode.emptyPhone);
      });

      test('trả về error code khi số điện thoại là null', () {
        final result = controller.validatePhone(null);
        expect(result, RegisterErrorCode.emptyPhone);
      });
    });

    group('validateEmail', () {
      test('trả về null khi email hợp lệ', () {
        final result = controller.validateEmail('test@example.com');
        expect(result, isNull);
      });

      test('trả về error code khi email trống', () {
        final result = controller.validateEmail('');
        expect(result, RegisterErrorCode.emptyEmail);
      });

      test('trả về error code khi email không hợp lệ', () {
        final result = controller.validateEmail('invalid-email');
        expect(result, RegisterErrorCode.invalidEmail);
      });

      test('trả về error code khi email thiếu @', () {
        final result = controller.validateEmail('testexample.com');
        expect(result, RegisterErrorCode.invalidEmail);
      });

      test('trả về error code khi email là null', () {
        final result = controller.validateEmail(null);
        expect(result, RegisterErrorCode.emptyEmail);
      });

      test('trả về null khi email có định dạng phức tạp hợp lệ', () {
        final result = controller.validateEmail('user.name_99@example.co.uk');
        expect(result, isNull);
      });
    });

    group('validatePassword', () {
      test('trả về null khi mật khẩu hợp lệ', () {
        final result = controller.validatePassword('password123');
        expect(result, isNull);
      });

      test('trả về error code khi mật khẩu trống', () {
        final result = controller.validatePassword('');
        expect(result, RegisterErrorCode.emptyPassword);
      });

      test('trả về error code khi mật khẩu quá ngắn', () {
        final result = controller.validatePassword('12345');
        expect(result, RegisterErrorCode.passwordTooShort);
      });

      test('trả về error code khi mật khẩu là null', () {
        final result = controller.validatePassword(null);
        expect(result, RegisterErrorCode.emptyPassword);
      });

      test('trả về null khi mật khẩu có đúng 6 ký tự', () {
        final result = controller.validatePassword('123456');
        expect(result, isNull);
      });
    });

    group('validateConfirmPassword', () {
      test('trả về null khi xác nhận mật khẩu khớp', () {
        controller.passwordController.text = 'password123';
        final result = controller.validateConfirmPassword('password123');
        expect(result, isNull);
      });

      test('trả về error code khi xác nhận mật khẩu trống', () {
        controller.passwordController.text = 'password123';
        final result = controller.validateConfirmPassword('');
        expect(result, RegisterErrorCode.emptyConfirmPassword);
      });

      test('trả về error code khi xác nhận mật khẩu không khớp', () {
        controller.passwordController.text = 'password123';
        final result = controller.validateConfirmPassword('password456');
        expect(result, RegisterErrorCode.passwordMismatch);
      });

      test('trả về error code khi xác nhận mật khẩu là null', () {
        controller.passwordController.text = 'password123';
        final result = controller.validateConfirmPassword(null);
        expect(result, RegisterErrorCode.emptyConfirmPassword);
      });
    });

    group('validateTerms', () {
      test('trả về null khi điều khoản được chấp nhận', () {
        final result = controller.validateTerms(true);
        expect(result, isNull);
      });

      test('trả về error code khi điều khoản không được chấp nhận', () {
        final result = controller.validateTerms(false);
        expect(result, RegisterErrorCode.termsNotAccepted);
      });
    });

    group('validateAllFields', () {
      test('trả về null khi tất cả trường hợp lệ', () {
        controller.fullNameController.text = 'John Doe';
        controller.phoneController.text = '0123456789';
        controller.emailController.text = 'test@example.com';
        controller.passwordController.text = 'password123';
        controller.confirmPasswordController.text = 'password123';

        final result = controller.validateAllFields(true);
        expect(result, isNull);
      });

      test('trả về lỗi họ và tên khi họ và tên trống', () {
        controller.fullNameController.text = '';
        controller.phoneController.text = '0123456789';
        controller.emailController.text = 'test@example.com';
        controller.passwordController.text = 'password123';
        controller.confirmPasswordController.text = 'password123';

        final result = controller.validateAllFields(true);
        expect(result, RegisterErrorCode.emptyFullName);
      });

      test('trả về lỗi email khi email không hợp lệ', () {
        controller.fullNameController.text = 'John Doe';
        controller.phoneController.text = '0123456789';
        controller.emailController.text = 'invalid-email';
        controller.passwordController.text = 'password123';
        controller.confirmPasswordController.text = 'password123';

        final result = controller.validateAllFields(true);
        expect(result, RegisterErrorCode.invalidEmail);
      });

      test('trả về lỗi mật khẩu khi mật khẩu quá ngắn', () {
        controller.fullNameController.text = 'John Doe';
        controller.phoneController.text = '0123456789';
        controller.emailController.text = 'test@example.com';
        controller.passwordController.text = '123';
        controller.confirmPasswordController.text = '123';

        final result = controller.validateAllFields(true);
        expect(result, RegisterErrorCode.passwordTooShort);
      });

      test('trả về lỗi điều khoản khi không chấp nhận', () {
        controller.fullNameController.text = 'John Doe';
        controller.phoneController.text = '0123456789';
        controller.emailController.text = 'test@example.com';
        controller.passwordController.text = 'password123';
        controller.confirmPasswordController.text = 'password123';

        final result = controller.validateAllFields(false);
        expect(result, RegisterErrorCode.termsNotAccepted);
      });
    });
  });

  group('RegisterController - Service Tests', () {
    late RegisterController controller;
    late _AuthStub authStub;
    late _DataMigrationStub dataMigrationStub;

    setUp(() {
      authStub = _AuthStub();
      dataMigrationStub = _DataMigrationStub(authService: authStub);
      controller = RegisterController(
        authService: authStub,
        dataMigrationService: dataMigrationStub,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('testFirebaseConnection trả về true khi kết nối thành công', () async {
      authStub.firebaseConnectionToReturn = true;
      final result = await controller.testFirebaseConnection();
      expect(result, true);
    });

    test('testFirebaseConnection trả về false khi kết nối thất bại', () async {
      authStub.firebaseConnectionToReturn = false;
      final result = await controller.testFirebaseConnection();
      expect(result, false);
    });

    test('isEmailAlreadyInUse trả về true khi email đã được sử dụng', () async {
      authStub.emailInUseToReturn = true;
      final result = await controller.isEmailAlreadyInUse('test@example.com');
      expect(result, true);
    });

    test(
      'isEmailAlreadyInUse trả về false khi email chưa được sử dụng',
      () async {
        authStub.emailInUseToReturn = false;
        final result = await controller.isEmailAlreadyInUse('test@example.com');
        expect(result, false);
      },
    );
  });

  group('RegisterController - SignUp Tests', () {
    late RegisterController controller;
    late _AuthStub authStub;
    late _DataMigrationStub dataMigrationStub;

    setUp(() {
      authStub = _AuthStub();
      dataMigrationStub = _DataMigrationStub(authService: authStub);
      controller = RegisterController(
        authService: authStub,
        dataMigrationService: dataMigrationStub,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('signUp trả về success khi đăng ký thành công', () async {
      authStub.userToReturn = MockUser(uid: 'test-uid');
      controller.fullNameController.text = 'John Doe';
      controller.phoneController.text = '0123456789';
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';

      final result = await controller.signUp();

      expect(result.isSuccess, true);
      expect(result.userId, 'test-uid');
      expect(result.errorCode, isNull);
    });

    test('signUp trả về failure khi user là null', () async {
      authStub.userToReturn = null;
      controller.fullNameController.text = 'John Doe';
      controller.phoneController.text = '0123456789';
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';

      final result = await controller.signUp();

      expect(result.isSuccess, false);
      expect(result.errorCode, RegisterErrorCode.registrationFailed);
      expect(result.userId, isNull);
    });

    test('signUp trả về failure khi email đã được sử dụng', () async {
      authStub.signUpException = const AuthException(
        'Email already in use',
        'email-already-in-use',
      );
      controller.fullNameController.text = 'John Doe';
      controller.phoneController.text = '0123456789';
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';

      final result = await controller.signUp();

      expect(result.isSuccess, false);
      expect(result.errorCode, RegisterErrorCode.emailAlreadyInUse);
    });

    test('signUp trả về failure khi mật khẩu yếu', () async {
      authStub.signUpException = const AuthException(
        'Password is weak',
        'weak-password',
      );
      controller.fullNameController.text = 'John Doe';
      controller.phoneController.text = '0123456789';
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';

      final result = await controller.signUp();

      expect(result.isSuccess, false);
      expect(result.errorCode, RegisterErrorCode.weakPassword);
    });

    test('signUp trả về failure khi có exception khác', () async {
      authStub.signUpException = Exception('Unknown error');
      controller.fullNameController.text = 'John Doe';
      controller.phoneController.text = '0123456789';
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = 'password123';

      final result = await controller.signUp();

      expect(result.isSuccess, false);
      expect(result.errorCode, RegisterErrorCode.registrationFailed);
    });
  });

  group('RegisterController - Onboarding Data Tests', () {
    test('khởi tạo với preSelectedData', () {
      final preData = {
        'gender': 'male',
        'heightCm': 170,
        'weightKg': 70,
        'age': 25,
      };

      final controller = RegisterController(preSelectedData: preData);

      expect(controller.onboardingData, preData);
      controller.dispose();
    });

    test('khởi tạo mà không có preSelectedData', () {
      final controller = RegisterController();

      expect(controller.onboardingData, isEmpty);
      controller.dispose();
    });
  });

  group('RegisterResult Tests', () {
    test('RegisterResult.success tạo kết quả thành công', () {
      final result = RegisterResult.success(userId: 'test-uid');

      expect(result.isSuccess, true);
      expect(result.userId, 'test-uid');
      expect(result.errorCode, isNull);
      expect(result.error, isNull);
    });

    test('RegisterResult.failure tạo kết quả thất bại', () {
      final result = RegisterResult.failure(RegisterErrorCode.emptyEmail);

      expect(result.isSuccess, false);
      expect(result.errorCode, RegisterErrorCode.emptyEmail);
      expect(result.userId, isNull);
      expect(result.error, RegisterErrorCode.emptyEmail);
    });
  });
}
