import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CameraPreviewWrapper
/// - Encapsulates error/loading/preview rendering
/// - Keeps the aspect ratio correction logic centralized
class CameraPreviewWrapper extends StatelessWidget {
  final CameraController? controller;
  final bool isInitializing;
  final String? errorMessage;

  const CameraPreviewWrapper({
    super.key,
    required this.controller,
    required this.isInitializing,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    if (isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final ctrl = controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // Camera sensor usually provides landscape (horizontal), but app uses portrait (vertical).
    // Invert ratio so portrait preview matches captured photo.
    final previewAspectRatio = ctrl.value.aspectRatio;
    if (previewAspectRatio <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        if (maxWidth <= 0 || maxHeight <= 0) {
          return const SizedBox.shrink();
        }

        // Convert ratio from landscape to portrait.
        final correctedAspectRatio = 1 / previewAspectRatio;

        return Center(
          child: AspectRatio(
            aspectRatio: correctedAspectRatio,
            child: CameraPreview(ctrl),
          ),
        );
      },
    );
  }
}

