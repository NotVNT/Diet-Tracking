import 'package:flutter/material.dart';
import '../../common/app_colors.dart';
import '../../common/app_styles.dart';

class HealthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;

  const HealthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmitted,
  });

  @override
  State<HealthTextField> createState() => _HealthTextFieldState();
}

class _HealthTextFieldState extends State<HealthTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: AppStyles.inputDecorationWithFocus(_focused),
          child: TextField(
            controller: widget.controller,
            onSubmitted: widget.onSubmitted,
            decoration: AppStyles.inputDecorationWithHint(widget.hintText)
                .copyWith(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
            style: const TextStyle(color: AppColors.black, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
