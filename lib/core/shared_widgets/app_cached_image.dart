import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/shared_widgets/app_skeleton_loader.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fallbackIcon = Icons.image_not_supported_rounded,
    this.memCacheWidth,
    this.memCacheHeight,
    this.isCircle = false,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final IconData fallbackIcon;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final bool isCircle;

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackShape = isCircle ? BoxShape.circle : BoxShape.rectangle;
    final fallbackRadius = isCircle
        ? null
        : (borderRadius ?? BorderRadius.circular(12));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: fallbackShape,
        borderRadius: fallbackRadius,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (width != null && width! < 60) ? 20 : 32,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildFallback(context);
    }

    final url = imageUrl!.trim();
    final safeWidth = (width != null && width!.isFinite && width! > 0)
        ? width
        : null;
    final safeHeight = (height != null && height!.isFinite && height! > 0)
        ? height
        : null;

    final resolvedCacheWidth =
        memCacheWidth ?? (safeWidth != null ? (safeWidth * 2.5).round() : null);
    final resolvedCacheHeight =
        memCacheHeight ??
        (safeHeight != null ? (safeHeight * 2.5).round() : null);

    final imageWidget = Image.network(
      url,
      width: safeWidth,
      height: safeHeight,
      fit: fit,
      cacheWidth: resolvedCacheWidth,
      cacheHeight: resolvedCacheHeight,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            SizedBox(
              width: safeWidth,
              height: safeHeight,
              child: isCircle
                  ? AppSkeletonLoader.circle(
                      size: safeWidth ?? safeHeight ?? 44,
                    )
                  : AppSkeletonLoader.card(height: safeHeight ?? 100),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildFallback(context);
      },
    );

    if (isCircle) {
      return ClipOval(child: imageWidget);
    }

    final effectiveRadius = borderRadius ?? BorderRadius.circular(12);
    return ClipRRect(borderRadius: effectiveRadius, child: imageWidget);
  }
}
