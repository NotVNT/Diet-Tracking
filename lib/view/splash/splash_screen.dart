import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/home_page/presentation/pages/home_page.dart';
import '../../view/on_boarding/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  double _progress = 0.0; // 0..1
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Tăng tiến độ từ từ đến 100% rồi vào app
    const tick = Duration(milliseconds: 20); // ~2s đến 100%
    const step = 0.01; // 1% mỗi tick
    _timer = Timer.periodic(tick, (t) {
      if (!mounted) return;
      setState(() {
        _progress += step;
        if (_progress >= 1.0) {
          _progress = 1.0;
          t.cancel();
          _goToHome();
        }
      });
    });
  }

  void _goToHome() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    final destination = user == null ? const WelcomeScreen() : const HomePage();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh nền full màn hình
          FadeTransition(
            opacity: _fadeIn,
            child: Image.asset(
              'assets/logo/load_image.png',
              fit: BoxFit.cover, // phủ full, cắt tràn nếu cần
            ),
          ),

          // Overlay thanh loading và text đè lên ảnh
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: _progress, // 0..1
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đang tải... ${(_progress * 100).toInt()}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
