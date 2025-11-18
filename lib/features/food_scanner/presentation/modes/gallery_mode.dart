import 'package:flutter/material.dart';

/// View rendered when the user wants to pick a photo from the gallery.
class GalleryModeView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPick;

  const GalleryModeView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.image_outlined),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
