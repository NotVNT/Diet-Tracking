import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget hiển thị thông tin về ứng dụng
/// Bao gồm tên app, phiên bản và thông tin bản quyền
class AppInfoSection extends StatelessWidget {
  final String appName;
  final String version;
  final String? description;
  final EdgeInsetsGeometry? padding;

  const AppInfoSection({
    super.key,
    this.appName = 'Diet Tracking',
    this.version = '1.0.0',
    this.description,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          // App Name
          Text(
            appName,
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Phiên bản $version',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          // Description (optional)
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Copyright
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '2025 VGP - Diet Tracking Team',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Additional info
          Text(
            'All Rights Reserved',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version cho trường hợp cần hiển thị ngắn gọn
class AppInfoCompact extends StatelessWidget {
  final String appName;
  final String version;

  const AppInfoCompact({
    super.key,
    this.appName = 'Diet Tracking',
    this.version = '1.0.0',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$appName v$version',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
