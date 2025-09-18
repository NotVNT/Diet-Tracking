import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login/login_screen.dart';
import '../../common/language_selector.dart';
import '../../common/custom_button.dart';
import 'started_view/started_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;
  int _currentImageIndex = 0;
  Language _selectedLanguage = Language.vi;

  final List<String> _images = [
    'assets/welcome_screen/flexitarian-diet-foods_OCES.jpg',
    'assets/welcome_screen/holding-schematic-meal-plan-di-4012-3914-1658462990.webp',
    'assets/welcome_screen/diet.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _arrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.elasticInOut,
      ),
    );

    _animationController.forward();

    // Bắt đầu animation mũi tên sau khi màn hình load xong
    Future.delayed(const Duration(milliseconds: 2000), () {
      _arrowAnimationController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _arrowAnimationController.dispose();
    super.dispose();
  }

  void _showImageDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.asset(_images[index], fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              // Bỏ nút X, chạm vào overlay/ảnh sẽ đóng dialog
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              LanguageSelector(
                selected: _selectedLanguage,
                onChanged: (lang) {
                  setState(() {
                    _selectedLanguage = lang;
                  });
                },
              ),
              const SizedBox(height: 12),

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    _selectedLanguage == Language.vi
                        ? 'Bắt đầu theo dõi\nchế độ ăn kiêng của bạn hôm nay!'
                        : 'Start tracking your\ndiet plan today!',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    _selectedLanguage == Language.vi
                        ? 'Theo dõi chế độ ăn kiêng hàng ngày với\nkế hoạch bữa ăn cá nhân hóa và\nkhuyến nghị thông minh.'
                        : 'Track your daily diet with\npersonalized meal plans and\nsmart recommendations.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _showImageDialog(context, index);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      _images[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _images.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentImageIndex == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
                                    ? const Color(0xFF9C27B0)
                                    : Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF9C27B0,
                                  ).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StartScreen(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedLanguage == Language.vi
                                          ? 'Bắt đầu ngay'
                                          : 'Get started',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    AnimatedBuilder(
                                      animation: _arrowAnimation,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            _arrowAnimation.value * 8,
                                            0,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white.withOpacity(
                                                  0.6,
                                                ),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white.withOpacity(
                                                  0.4,
                                                ),
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: CustomButton(
                            text: 'Đăng nhập',
                            backgroundColor: const Color(0xFF1F2A37),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            height: 56,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
