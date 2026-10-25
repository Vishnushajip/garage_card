import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';

class SplashRevealPainter extends CustomPainter {
  const SplashRevealPainter({
    required this.progress,
    this.revealColor = AppColors.primaryRed,
    this.deepColor = AppColors.primaryRedDark,
    this.glowColor = AppColors.primaryRedLight,
  });

  final double progress;
  final Color revealColor;
  final Color deepColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final width = size.width;
    final height = size.height;

    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.25,
        colors: [revealColor, deepColor],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (progress >= 1.0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), fillPaint);
      return;
    }

    final dx = (width / 2.0) * progress;
    final dy = (height / 2.0) * progress;

    final innerWidth = (width - 2 * dx).clamp(0.0, width);
    final innerHeight = (height - 2 * dy).clamp(0.0, height);

    if (innerWidth <= 0.0 || innerHeight <= 0.0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), fillPaint);
      return;
    }

    final innerRect = Rect.fromLTWH(dx, dy, innerWidth, innerHeight);
    final cornerRadius = Radius.circular(
      (32.0 * (1.0 - progress)).clamp(0.0, 32.0),
    );
    final innerRRect = RRect.fromRectAndRadius(innerRect, cornerRadius);

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(innerRRect);

    canvas.drawPath(path, fillPaint);

    final innerShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28 * (1.0 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..isAntiAlias = true;
    canvas.drawRRect(innerRRect, innerShadowPaint);

    final glowBorderPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..isAntiAlias = true;
    canvas.drawRRect(innerRRect, glowBorderPaint);

    final accentLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45 * (1.0 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;
    canvas.drawRRect(innerRRect.deflate(1.5), accentLinePaint);
  }

  @override
  bool shouldRepaint(covariant SplashRevealPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.revealColor != revealColor ||
        oldDelegate.deepColor != deepColor ||
        oldDelegate.glowColor != glowColor;
  }
}
