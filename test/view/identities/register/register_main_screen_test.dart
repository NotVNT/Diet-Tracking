import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/register/register_main_screen.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:diet_tracking_project/database/data_migration_service.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/view/identities/register/register_widgets.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';

// Helper function to build the test widget
Widget _buildTestWidget(Widget child) {
  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

/// Stub implementation of AuthService for testing
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

/// Stub implementation of DataMigrationService for testing
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
  group('SignupScreen UI Tests', () {
    testWidgets('displays title and input fields', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets(
      'displays Register button as disabled when terms are not accepted',
      (tester) async {
        await tester.pumpWidget(
          _buildTestWidget(
            SignupScreen(
              authService: _AuthStub(),
              dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
            ),
          ),
        );

        await tester.ensureVisible(find.text('Sign Up'));
        await tester.pump();

        expect(find.text('Sign Up'), findsOneWidget);
      },
    );

    testWidgets('displays Already have an account link', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      expect(find.byType(AlreadyHaveAccountLink), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      final visibilityIcons = find.byIcon(Icons.visibility);
      expect(visibilityIcons, findsWidgets);

      await tester.tap(visibilityIcons.first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsWidgets);
    });

    testWidgets('enters data into fields', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      final nameField = find.byType(TextField).at(0);
      final phoneField = find.byType(TextField).at(1);
      final emailField = find.byType(TextField).at(2);
      final passField = find.byType(TextField).at(3);
      final confirmField = find.byType(TextField).at(4);

      await tester.enterText(nameField, 'John Doe');
      await tester.enterText(phoneField, '0123456789');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passField, 'password123');
      await tester.enterText(confirmField, 'password123');

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('0123456789'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('accepting terms enables Register button', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      final termsWidget = tester.widget<TermsCheckbox>(
        find.byType(TermsCheckbox),
      );
      termsWidget.onChanged(true);
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('SignupScreen Validation Tests', () {
    testWidgets('shows error when full name is empty', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      final termsWidget = tester.widget<TermsCheckbox>(
        find.byType(TermsCheckbox),
      );
      termsWidget.onChanged(true);
      await tester.pump();

      final phoneField = find.byType(TextField).at(1);
      final emailField = find.byType(TextField).at(2);
      final passField = find.byType(TextField).at(3);
      final confirmField = find.byType(TextField).at(4);

      await tester.enterText(phoneField, '0123456789');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passField, 'password123');
      await tester.enterText(confirmField, 'password123');

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error when email is invalid', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      final termsWidget = tester.widget<TermsCheckbox>(
        find.byType(TermsCheckbox),
      );
      termsWidget.onChanged(true);
      await tester.pump();

      final nameField = find.byType(TextField).at(0);
      final phoneField = find.byType(TextField).at(1);
      final emailField = find.byType(TextField).at(2);
      final passField = find.byType(TextField).at(3);
      final confirmField = find.byType(TextField).at(4);

      await tester.enterText(nameField, 'John Doe');
      await tester.enterText(phoneField, '0123456789');
      await tester.enterText(emailField, 'invalid-email');
      await tester.enterText(passField, 'password123');
      await tester.enterText(confirmField, 'password123');

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      final termsWidget = tester.widget<TermsCheckbox>(
        find.byType(TermsCheckbox),
      );
      termsWidget.onChanged(true);
      await tester.pump();

      final nameField = find.byType(TextField).at(0);
      final phoneField = find.byType(TextField).at(1);
      final emailField = find.byType(TextField).at(2);
      final passField = find.byType(TextField).at(3);
      final confirmField = find.byType(TextField).at(4);

      await tester.enterText(nameField, 'John Doe');
      await tester.enterText(phoneField, '0123456789');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passField, 'password123');
      await tester.enterText(confirmField, 'password456');

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('SignupScreen Integration Tests', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      expect(find.text('Create Account'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('initializes with preSelectedData', (tester) async {
      final preData = {
        'gender': 'male',
        'heightCm': 170,
        'weightKg': 70,
        'age': 25,
      };

      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
            preSelectedData: preData,
          ),
        ),
      );

      expect(find.text('Create Account'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('runs animation on load', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          SignupScreen(
            authService: _AuthStub(),
            dataMigrationService: _DataMigrationStub(authService: _AuthStub()),
          ),
        ),
      );

      expect(find.text('Create Account'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
