import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showBadge = true,
    this.showWordmark = false,
    this.isWhiteVariant = false,
    this.useAssetImage = false,
    this.customColor,
    this.tagline,
  });

  final double size;
  final bool showBadge;
  final bool showWordmark;
  final bool isWhiteVariant;
  final bool useAssetImage;
  final Color? customColor;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(size * (20.0 / 72.0));
    final symbol = SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: showBadge
              ? [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                    blurRadius: size * 0.4,
                    offset: Offset(0, size * 0.16),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Image.asset(
            'assets/branding/wefix_logo_120x120.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    if (!showWordmark) {
      return symbol;
    }

    final textColor = isWhiteVariant
        ? Colors.white
        : AppColors.textPrimaryLight;
    final subtitleColor = isWhiteVariant
        ? Colors.white.withValues(alpha: 0.75)
        : AppColors.textSecondaryLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        symbol,
        SizedBox(width: size * 0.25),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WeFix',
              style: AppFonts.displayLarge(color: textColor).copyWith(
                fontSize: size * 0.52,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
            SizedBox(height: size * 0.05),
            Text(
              tagline ?? 'Smarter Garage Management',
              style: AppFonts.labelSmall(color: subtitleColor).copyWith(
                fontSize: size * 0.19,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WeFixCarPainter extends CustomPainter {
  const WeFixCarPainter({this.color = Colors.white});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(19, 17)
      ..lineTo(21, 17)
      ..arcToPoint(const Offset(22, 16), radius: const Radius.circular(1))
      ..lineTo(22, 13)
      ..cubicTo(22, 12.1, 21.3, 11.3, 20.5, 11.1)
      ..cubicTo(18.7, 10.6, 16, 10, 16, 10)
      ..cubicTo(16, 10, 14.7, 8.6, 13.8, 7.7)
      ..cubicTo(13.3, 7.3, 12.7, 7, 12, 7)
      ..lineTo(5, 7)
      ..cubicTo(4.4, 7, 3.9, 7.4, 3.6, 7.9)
      ..lineTo(2.2, 10.8)
      ..arcToPoint(const Offset(2, 12), radius: const Radius.circular(3.7))
      ..lineTo(2, 16)
      ..arcToPoint(const Offset(3, 17), radius: const Radius.circular(1))
      ..lineTo(5, 17);
    canvas.drawPath(body, paint);

    canvas.drawCircle(const Offset(7, 17), 2, paint);

    final bottomLine = Path()
      ..moveTo(9, 17)
      ..lineTo(15, 17);
    canvas.drawPath(bottomLine, paint);

    canvas.drawCircle(const Offset(17, 17), 2, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WeFixCarPainter oldDelegate) =>
      oldDelegate.color != color;
}

class WeFixSymbolPainter extends CustomPainter {
  const WeFixSymbolPainter({required this.color, this.showAccent = true});

  final Color color;
  final bool showAccent;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 512.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final leftWing = Path()
      ..moveTo(112, 168)
      ..cubicTo(112, 150, 128, 138, 144, 146)
      ..lineTo(206, 342)
      ..cubicTo(212, 360, 198, 376, 180, 376)
      ..cubicTo(168, 376, 158, 368, 152, 356)
      ..lineTo(98, 186)
      ..cubicTo(94, 176, 98, 168, 112, 168)
      ..close();
    canvas.drawPath(leftWing, paint);

    final centerWrench = Path()
      ..moveTo(186, 362)
      ..lineTo(232, 236)
      ..cubicTo(235, 228, 244, 222, 254, 222)
      ..lineTo(258, 222)
      ..cubicTo(268, 222, 277, 228, 280, 236)
      ..lineTo(326, 362)
      ..cubicTo(332, 378, 318, 392, 302, 392)
      ..cubicTo(290, 392, 280, 384, 276, 372)
      ..lineTo(256, 312)
      ..lineTo(236, 372)
      ..cubicTo(232, 384, 222, 392, 210, 392)
      ..cubicTo(194, 392, 180, 378, 186, 362)
      ..close();
    canvas.drawPath(centerWrench, paint);

    final wrenchNotch = Path()
      ..moveTo(238, 180)
      ..cubicTo(238, 170, 246, 162, 256, 162)
      ..cubicTo(266, 162, 274, 170, 274, 180)
      ..lineTo(274, 206)
      ..cubicTo(268, 202, 262, 200, 256, 200)
      ..cubicTo(250, 200, 244, 202, 238, 206)
      ..close();
    canvas.drawPath(wrenchNotch, paint);

    final rightWing = Path()
      ..moveTo(306, 342)
      ..lineTo(396, 142)
      ..cubicTo(402, 128, 418, 122, 430, 130)
      ..cubicTo(442, 138, 444, 154, 438, 168)
      ..lineTo(332, 364)
      ..cubicTo(326, 376, 314, 382, 302, 380)
      ..cubicTo(292, 378, 286, 368, 290, 358)
      ..close();
    canvas.drawPath(rightWing, paint);

    if (showAccent) {
      final accentPaint = Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawCircle(const Offset(432, 132), 14, accentPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WeFixSymbolPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.showAccent != showAccent;
  }
}
