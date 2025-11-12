import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_styles.dart';
import '../responsive/responsive.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 56,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.isEnabled && widget.onPressed != null) {
      _pressController.forward().then((_) {
        _pressController.reverse();
      });
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !widget.isEnabled || widget.onPressed == null;
    final responsive = ResponsiveHelper.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.width ?? double.infinity,
            height: responsive.height(widget.height),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(responsive.radius(AppStyles.radiusL)),
                onTap: isDisabled ? null : _handlePress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isDisabled
                        ? null
                        : LinearGradient(
                            colors: widget.backgroundColor != null
                                ? [
                                    widget.backgroundColor!,
                                    widget.backgroundColor!,
                                  ]
                                : AppColors.primaryGradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    color: isDisabled ? AppColors.grey300 : null,
                    borderRadius: BorderRadius.circular(responsive.radius(AppStyles.radiusL)),
                    boxShadow: isDisabled
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Stack(
                    children: [
                      // Ripple effect
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                responsive.radius(AppStyles.radiusL),
                              ),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: _rippleAnimation.value * 2,
                                colors: [
                                  Colors.white.withOpacity(
                                    0.3 * (1 - _rippleAnimation.value),
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Button content
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.isLoading) ...[
                              SizedBox(
                                width: responsive.iconSize(20),
                                height: responsive.iconSize(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.textColor ?? AppColors.white,
                                  ),
                                ),
                              ),
                              responsive.horizontalSpace(12),
                            ] else if (widget.icon != null) ...[
                              widget.icon!,
                              responsive.horizontalSpace(12),
                            ],
                            Text(
                              widget.text,
                              style: GoogleFonts.inter(
                                fontSize: responsive.fontSize(16),
                                fontWeight: FontWeight.w600,
                                color:
                                    widget.textColor ??
                                    (isDisabled
                                        ? AppColors.grey500
                                        : AppColors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
