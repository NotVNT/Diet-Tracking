import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Performance optimization utilities for the Diet Tracking app
class PerformanceUtils {
  /// Configure global image cache to reduce decoding spikes.
  static void configureImageCaching({int? maxCount, int? maxBytes}) {
    // Tune the global image cache. Large values reduce re-decoding but may use more RAM.
    final cache = PaintingBinding.instance.imageCache;
    if (maxCount != null) cache.maximumSize = maxCount; // number of images
    if (maxBytes != null) cache.maximumSizeBytes = maxBytes; // in bytes
  }

  /// Calculate cache dimension close to physical pixels of displayed size.
  static (int, int) _memCacheSize(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    final dpr = MediaQuery.of(context).devicePixelRatio.clamp(1.0, 3.0);
    final w = (width * dpr).round();
    final h = (height * dpr).round();
    // Cap to avoid decoding very large sources
    return (math.min(w, 256), math.min(h, 256));
  }

  /// Create a cached network image with lightweight placeholder and proper cache sizing.
  static Widget buildCachedImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return LayoutBuilder(
      builder: (context, _) {
        final (memW, memH) = _memCacheSize(context, width: width, height: height);
        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: memW,
          memCacheHeight: memH,
          filterQuality: FilterQuality.low,
          placeholder: (context, url) =>
              placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[200],
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
      },
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
