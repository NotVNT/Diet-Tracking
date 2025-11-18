import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog yêu cầu quyền truy cập camera và thư viện ảnh
/// 
/// Widget này hiển thị dialog để yêu cầu người dùng cấp quyền
/// truy cập camera và thư viện ảnh khi sử dụng tính năng quét thức ăn
class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final AsyncCallback onAllow;
  final AsyncCallback onAllowOnce;
  final AsyncCallback onDeny;
  final String allowLabel;
  final String allowOnceLabel;
  final String denyLabel;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onAllow,
    required this.onAllowOnce,
    required this.onDeny,
    this.allowLabel = 'TRONG KHI DÙNG ỨNG DỤNG',
    this.allowOnceLabel = 'CHỈ LẦN NÀY',
    this.denyLabel = 'KHÔNG CHO PHÉP',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D3D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.videocam,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (message.isNotEmpty) ...[
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            
            // Allow button
            _buildButton(
              context: context,
              text: allowLabel,
              color: const Color(0xFF2196F3),
              onTap: onAllow,
            ),
            const SizedBox(height: 12),
            
            // Allow once button
            _buildButton(
              context: context,
              text: allowOnceLabel,
              color: const Color(0xFF4D4D4D),
              onTap: onAllowOnce,
            ),
            const SizedBox(height: 12),
            
            // Deny button
            _buildButton(
              context: context,
              text: denyLabel,
              color: const Color(0xFF4D4D4D),
              onTap: onDeny,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required Color color,
    required AsyncCallback onTap,
  }) {
    return InkWell(
      onTap: () async {
        await onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
