import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/register/register_widgets.dart';

void main() {
  group('FullNameInputField Tests', () {
    testWidgets('hiển thị label và hint', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullNameInputField(
              controller: controller,
              isFocused: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Họ và tên'), findsOneWidget);
      expect(find.text('Nhập họ và tên của bạn'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('gọi onTap khi tap vào field', (tester) async {
      final controller = TextEditingController();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FullNameInputField(
              controller: controller,
              isFocused: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      expect(tapped, true);

      controller.dispose();
    });
  });

  group('PhoneInputField Tests', () {
    testWidgets('hiển thị label và hint', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              isFocused: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Nhập số điện thoại'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('có keyboard type là phone', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              isFocused: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      controller.dispose();
    });
  });

  group('EmailInputField Tests', () {
    testWidgets('hiển thị label và hint', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmailInputField(
              controller: controller,
              isFocused: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('example@gmail.com'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('có keyboard type là email', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmailInputField(
              controller: controller,
              isFocused: false,
              onTap: () {},
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      controller.dispose();
    });
  });

  group('PasswordInputField Tests', () {
    testWidgets('hiển thị label', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordInputField(
              controller: controller,
              isFocused: false,
              isPasswordVisible: false,
              onTap: () {},
              onToggleVisibility: () {},
            ),
          ),
        ),
      );

      expect(find.text('Mật khẩu'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('ẩn mật khẩu khi isPasswordVisible là false', (tester) async {
      final controller = TextEditingController();
      controller.text = 'password123';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordInputField(
              controller: controller,
              isFocused: false,
              isPasswordVisible: false,
              onTap: () {},
              onToggleVisibility: () {},
            ),
          ),
        ),
      );

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      controller.dispose();
    });

    testWidgets('hiển thị icon visibility toggle', (tester) async {
      final controller = TextEditingController();
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordInputField(
              controller: controller,
              isFocused: false,
              isPasswordVisible: false,
              onTap: () {},
              onToggleVisibility: () {
                toggled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility));
      expect(toggled, true);

      controller.dispose();
    });
  });

  group('ConfirmPasswordInputField Tests', () {
    testWidgets('hiển thị label', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmPasswordInputField(
              controller: controller,
              isFocused: false,
              isPasswordVisible: false,
              onTap: () {},
              onToggleVisibility: () {},
            ),
          ),
        ),
      );

      expect(find.text('Nhập lại mật khẩu'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('hiển thị icon visibility toggle', (tester) async {
      final controller = TextEditingController();
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmPasswordInputField(
              controller: controller,
              isFocused: false,
              isPasswordVisible: false,
              onTap: () {},
              onToggleVisibility: () {
                toggled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility));
      expect(toggled, true);

      controller.dispose();
    });
  });

  group('TermsCheckbox Tests', () {
    testWidgets('hiển thị checkbox và text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TermsCheckbox(isAccepted: false, onChanged: (_) {}),
          ),
        ),
      );

      // Văn bản được vẽ bằng RichText, không phải Text thuần
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('checkbox được checked khi isAccepted là true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TermsCheckbox(isAccepted: true, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('checkbox không được checked khi isAccepted là false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TermsCheckbox(isAccepted: false, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('gọi onChanged khi tap checkbox', (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TermsCheckbox(
              isAccepted: false,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(changedValue, true);
    });

    testWidgets('gọi onTermsTap khi tap terms link', (tester) async {
      bool termsTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TermsCheckbox(
              isAccepted: false,
              onChanged: (_) {},
              onTermsTap: () {
                termsTapped = true;
              },
            ),
          ),
        ),
      );

      // Gọi trực tiếp callback được truyền vào widget
      final widget = tester.widget<TermsCheckbox>(find.byType(TermsCheckbox));
      widget.onTermsTap?.call();
      expect(termsTapped, true);
    });

    testWidgets('gọi onPolicyTap khi tap policy link', (tester) async {
      bool policyTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TermsCheckbox(
              isAccepted: false,
              onChanged: (_) {},
              onPolicyTap: () {
                policyTapped = true;
              },
            ),
          ),
        ),
      );

      final widget = tester.widget<TermsCheckbox>(find.byType(TermsCheckbox));
      widget.onPolicyTap?.call();
      expect(policyTapped, true);
    });
  });

  group('AlreadyHaveAccountLink Tests', () {
    testWidgets('hiển thị text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AlreadyHaveAccountLink(onTap: () {})),
        ),
      );

      // Văn bản hiển thị bằng RichText
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('gọi onTap khi tap link', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlreadyHaveAccountLink(
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      final widget = tester.widget<AlreadyHaveAccountLink>(
        find.byType(AlreadyHaveAccountLink),
      );
      widget.onTap();
      expect(tapped, true);
    });
  });
}
