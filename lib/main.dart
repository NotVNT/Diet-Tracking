import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database/firebase_options.dart';
import 'view/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Web-only: đảm bảo dùng popup flow và giữ phiên đăng nhập
  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      // Nếu trước đó có redirect (do trình duyệt can thiệp), tiêu thụ kết quả để tránh trang handler lỗi
      await FirebaseAuth.instance.getRedirectResult();
    } catch (_) {
      // Bỏ qua lỗi web persistence/redirect nếu có
    }
  }
  await LanguageService.initialize();
  runApp(const DietTrackingApp());
}

class DietTrackingApp extends StatefulWidget {
  const DietTrackingApp({super.key});

  @override
  State<DietTrackingApp> createState() => _DietTrackingAppState();
}

class _DietTrackingAppState extends State<DietTrackingApp> {
  @override
  void initState() {
    super.initState();
    // Listen for language changes
    LanguageService.addLanguageListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.removeLanguageListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocalizations.of(context)?.appTitle ?? 'Diet Tracking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5722)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
      locale: LanguageService.currentLocale,
    );
  }
}
