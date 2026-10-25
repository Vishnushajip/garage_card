import 'dart:math' as math;

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
    final center = Offset(width / 2.0, height / 2.0);
    final maxRadius = math.sqrt(width * width + height * height) / 2.0 * 1.15;
    final currentRadius = maxRadius * progress;

    if (progress >= 1.0) {
      final fillPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [revealColor, deepColor],
        ).createShader(Rect.fromLTWH(0, 0, width, height))
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), fillPaint);
      return;
    }

    final circleRect = Rect.fromCircle(center: center, radius: currentRadius);
    final circlePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [glowColor, revealColor, deepColor],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(circleRect)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(center, currentRadius, circlePaint);

    final ringAlpha = (0.75 * (1.0 - progress * 0.4)).clamp(0.0, 1.0);
    final ringPaint = Paint()
      ..color = glowColor.withValues(alpha: ringAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
      ..isAntiAlias = true;
    canvas.drawCircle(center, currentRadius, ringPaint);

    final crestAlpha = (0.65 * (1.0 - progress * 0.5)).clamp(0.0, 1.0);
    final crestPaint = Paint()
      ..color = Colors.white.withValues(alpha: crestAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..isAntiAlias = true;
    canvas.drawCircle(center, currentRadius, crestPaint);
  }

  @override
  bool shouldRepaint(covariant SplashRevealPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.revealColor != revealColor ||
        oldDelegate.deepColor != deepColor ||
        oldDelegate.glowColor != glowColor;
  }
}
