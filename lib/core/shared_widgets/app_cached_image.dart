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

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
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
    final effectiveRadius = borderRadius ?? BorderRadius.circular(12);

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildFallback(context);
    }

    final url = imageUrl!.trim();

    final imageWidget = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            SizedBox(
              width: width,
              height: height,
              child: AppSkeletonLoader.card(height: 100),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildFallback(context);
      },
    );

    return ClipRRect(borderRadius: effectiveRadius, child: imageWidget);
  }
}
