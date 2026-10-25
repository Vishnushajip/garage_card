import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';

class SplashTachometerPainter extends CustomPainter {
  const SplashTachometerPainter({
    required this.arcProgress,
    required this.pulseValue,
    required this.sparkRippleProgress,
  });

  final double arcProgress;
  final double pulseValue;
  final double sparkRippleProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..color = AppColors.borderLight.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * math.pi / 180.0;
      final isMajor = i % 6 == 0;
      final tickLength = isMajor ? 6.0 : 3.5;
      final start = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final tickPaint = Paint()
        ..color = isMajor
            ? AppColors.primaryRed.withValues(alpha: 0.35)
            : AppColors.textMutedLight.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMajor ? 1.5 : 1.0
        ..isAntiAlias = true;
      canvas.drawLine(start, end, tickPaint);
    }

    if (arcProgress > 0.0) {
      final sweepAngle = 2 * math.pi * arcProgress.clamp(0.0, 1.0);
      final arcRect = Rect.fromCircle(center: center, radius: radius);

      final glowPaint = Paint()
        ..color = AppColors.primaryRedLight.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
        ..isAntiAlias = true;
      canvas.drawArc(arcRect, -math.pi / 2, sweepAngle, false, glowPaint);

      final arcPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [
            AppColors.primaryRedDark,
            AppColors.primaryRed,
            AppColors.primaryRedLight,
            Color(0xFFFEF08A),
          ],
        ).createShader(arcRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawArc(arcRect, -math.pi / 2, sweepAngle, false, arcPaint);
    }

    if (sparkRippleProgress > 0.0 && sparkRippleProgress < 1.0) {
      final sparkOrigin = Offset(
        center.dx + (radius * 0.65),
        center.dy - (radius * 0.55),
      );
      final rippleRadius = 28.0 * sparkRippleProgress;
      final rippleOpacity = (1.0 - sparkRippleProgress).clamp(0.0, 1.0);

      final ripplePaint = Paint()
        ..color = const Color(0xFFFEF08A)
            .withValues(alpha: 0.65 * rippleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * (1.0 - sparkRippleProgress)
        ..isAntiAlias = true;
      canvas.drawCircle(sparkOrigin, rippleRadius, ripplePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SplashTachometerPainter oldDelegate) {
    return oldDelegate.arcProgress != arcProgress ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.sparkRippleProgress != sparkRippleProgress;
  }
}
