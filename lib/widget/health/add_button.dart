import 'package:flutter/material.dart';
import '../../common/app_colors.dart';
import '../../common/app_styles.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const AddButton({super.key, required this.onPressed, this.label = 'Thêm'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: AppStyles.buttonText.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
