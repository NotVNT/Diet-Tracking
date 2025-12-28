import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../identities/login/login_main_screen.dart';
import '../../common/language_selector.dart';
import '../../common/custom_button.dart';
import '../../services/language_service.dart';
import '../../l10n/app_localizations.dart';
import '../../responsive/responsive.dart';
import 'started_view/started_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final WidgetBuilder? loginBuilder;
  const WelcomeScreen({super.key, this.loginBuilder});

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

  final List<String> _images = [
    'assets/welcome_screen/brand.png',
    'assets/welcome_screen/welcome_screen.png',
    'assets/welcome_screen/plan_eat.png',
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
    if (!const bool.fromEnvironment('FLUTTER_TEST')) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _arrowAnimationController.repeat(reverse: true);
      });
    }
  }

  Future<void> _onLanguageChanged(Language language) async {
    await LanguageService.changeLanguage(language);
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
    final responsive = ResponsiveHelper.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: responsive.edgePadding(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              responsive.verticalSpace(30),
              Row(
                children: [
                  Expanded(
                    child: LanguageSelector(
                      selected: LanguageService.currentLanguage,
                      onChanged: _onLanguageChanged,
                    ),
                  ),
                ],
              ),
              responsive.verticalSpace(12),

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    AppLocalizations.of(context)?.startTrackingToday ??
                        'Bắt đầu theo dõi\nchế độ ăn kiêng của bạn hôm nay!',
                    style: const bool.fromEnvironment('FLUTTER_TEST')
                        ? const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          )
                        : GoogleFonts.inter(
                            fontSize: responsive.fontSize(32),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.2,
                          ),
                  ),
                ),
              ),
              responsive.verticalSpace(15),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    AppLocalizations.of(context)?.trackDailyDiet ??
                        'Theo dõi chế độ ăn kiêng hàng ngày với\nkế hoạch bữa ăn cá nhân hóa và\nkhuyến nghị thông minh.',
                    style: const bool.fromEnvironment('FLUTTER_TEST')
                        ? const TextStyle(fontSize: 16, height: 1.5)
                        : GoogleFonts.inter(
                            fontSize: responsive.fontSize(16),
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            height: 1.5,
                          ),
                  ),
                ),
              ),
              responsive.verticalSpace(15),
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
                                  margin: responsive.edgePadding(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      responsive.radius(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      responsive.radius(20),
                                    ),
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
                        responsive.verticalSpace(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _images.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: responsive.edgePadding(horizontal: 4),
                              width: _currentImageIndex == index
                                  ? responsive.width(24)
                                  : responsive.width(8),
                              height: responsive.height(8),
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index
                                    ? const Color(0xFF9C27B0)
                                    : Colors.grey.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(
                                  responsive.radius(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              responsive.verticalSpace(40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: responsive.width(
                            MediaQuery.of(context).size.width * 0.85,
                          ),
                          height: responsive.height(56),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(
                                responsive.radius(28),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  responsive.radius(28),
                                ),
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
                                    responsive.horizontalSpace(12),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )?.getStarted ??
                                          'Bắt đầu ngay',
                                      style: const bool.fromEnvironment(
                                        'FLUTTER_TEST',
                                      )
                                          ? const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            )
                                          : GoogleFonts.inter(
                                              fontSize:
                                                  responsive.fontSize(16),
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onPrimary,
                                            ),
                                    ),
                                    responsive.horizontalSpace(12),
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
                                                color: colorScheme.onPrimary
                                                    .withValues(alpha: 0.8),
                                                size: responsive.iconSize(14),
                                              ),
                                              responsive.horizontalSpace(2),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: colorScheme.onPrimary
                                                    .withValues(alpha: 0.6),
                                                size: responsive.iconSize(14),
                                              ),
                                              responsive.horizontalSpace(2),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: colorScheme.onPrimary
                                                    .withValues(alpha: 0.4),
                                                size: responsive.iconSize(14),
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
                      responsive.verticalSpace(14),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: responsive.width(
                            MediaQuery.of(context).size.width * 0.85,
                          ),
                          child: CustomButton(
                            text:
                                AppLocalizations.of(context)?.login ??
                                'Đăng nhập',
                            backgroundColor: colorScheme.secondaryContainer,
                            textColor: colorScheme.onSecondaryContainer,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      widget.loginBuilder ??
                                      (context) => const LoginScreen(),
                                ),
                              );
                            },
                            height: responsive.height(56),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              responsive.verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }
}
