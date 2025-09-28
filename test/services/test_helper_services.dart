import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:diet_tracking_project/database/firebase_options.dart';

Future<void> globalTestInit() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  try {
    Firebase.app();
  } catch (_) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}


