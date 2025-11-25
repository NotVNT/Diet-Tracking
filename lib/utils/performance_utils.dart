import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Performance optimization utilities for the Diet Tracking app
class PerformanceUtils {
  /// Configure image caching with optimal settings
  static void configureImageCaching() {
    // CachedNetworkImage automatically handles caching
    // Default cache duration is 30 days
    // Cache size is limited to 100MB
  }

  /// Create a cached network image with error handling
  static Widget buildCachedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
    );
  }

  /// Wrap expensive widgets with RepaintBoundary for optimization
  static Widget wrapWithRepaintBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }

  /// Create a const SizedBox for better performance
  static const SizedBox spacer4 = SizedBox(height: 4, width: 4);
  static const SizedBox spacer8 = SizedBox(height: 8, width: 8);
  static const SizedBox spacer12 = SizedBox(height: 12, width: 12);
  static const SizedBox spacer16 = SizedBox(height: 16, width: 16);
  static const SizedBox spacer24 = SizedBox(height: 24, width: 24);
}

