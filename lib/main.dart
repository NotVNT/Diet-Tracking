import 'package:flutter/material.dart';
import '../view/on_boarding/welcome_screen.dart';

void main() {
  runApp(const DietTrackingApp());
}

class DietTrackingApp extends StatelessWidget {
  const DietTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Tracking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5722)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
