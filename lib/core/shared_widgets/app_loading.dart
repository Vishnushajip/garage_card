import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';

class AppLoading extends StatefulWidget {
  const AppLoading({
    super.key,
    this.message,
    this.showLogo = false,
    this.size = 54,
  });

  final String? message;
  final bool showLogo;
  final double size;

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _AutomotivePulsePainter(
                    progress: _controller.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 18),
            Text(
              widget.message!,
              style: AppFonts.bodyMedium(color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _AutomotivePulsePainter extends CustomPainter {
  const _AutomotivePulsePainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = isDark
          ? AppColors.borderDark.withValues(alpha: 0.35)
          : AppColors.borderLight;

    canvas.drawCircle(center, radius - 2, trackPaint);

    final startAngle = progress * 2 * math.pi;
    const sweepAngle = math.pi * 1.35;

    final sweepGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: math.pi * 2,
      colors: const [
        AppColors.primaryRed,
        AppColors.accentAmber,
        AppColors.primaryRed,
      ],
      transform: GradientRotation(startAngle),
    );

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0
      ..shader = sweepGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      startAngle,
      sweepAngle,
      false,
      sweepPaint,
    );

    final pulseScale = 0.85 + (math.sin(progress * 2 * math.pi) * 0.15);
    final innerPulsePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primaryRed.withValues(alpha: 0.16 * pulseScale);

    canvas.drawCircle(center, (radius - 12) * pulseScale, innerPulsePaint);

    final centerDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primaryRed;

    canvas.drawCircle(center, 3.5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _AutomotivePulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
