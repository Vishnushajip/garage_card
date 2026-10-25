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
  });

  final double size;
  final bool showBadge;
  final bool showWordmark;
  final bool isWhiteVariant;
  final bool useAssetImage;
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isWhiteVariant
        ? Colors.white
        : (customColor ?? AppColors.primaryRed);

    final symbol = SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          gradient: showBadge
              ? const LinearGradient(
                  colors: [AppColors.primaryRed, AppColors.primaryRedDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: showBadge ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: showBadge
              ? [
                  BoxShadow(
                    color: effectiveColor.withValues(alpha: 0.25),
                    blurRadius: size * 0.25,
                    offset: Offset(0, size * 0.1),
                  ),
                ]
              : null,
        ),
        padding: EdgeInsets.all(showBadge ? size * 0.16 : 0),
        child: CustomPaint(
          size: Size(size, size),
          painter: WeFixSymbolPainter(
            color: showBadge ? Colors.white : effectiveColor,
            showAccent: true,
          ),
        ),
      ),
    );

    final effectiveSymbol = (useAssetImage && showBadge)
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.28),
              boxShadow: [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: 0.28),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.28),
              child: Image.asset(
                'assets/branding/wefix_app_icon.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => symbol,
              ),
            ),
          )
        : symbol;

    if (!showWordmark) {
      return effectiveSymbol;
    }

    final textColor =
        isWhiteVariant ? Colors.white : AppColors.textPrimaryLight;
    final accentColor = isWhiteVariant ? Colors.white : AppColors.primaryRed;

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
            RichText(
              text: TextSpan(
                style: AppFonts.displayLarge(color: textColor).copyWith(
                  fontSize: size * 0.54,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1.0,
                ),
                children: [
                  const TextSpan(text: 'We'),
                  TextSpan(
                    text: 'Fix',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size * 0.06),
            Text(
              'VEHICLE SERVICE PLATFORM',
              style: AppFonts.labelSmall(
                color: isWhiteVariant
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.textMutedLight,
              ).copyWith(
                fontSize: size * 0.15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WeFixSymbolPainter extends CustomPainter {
  const WeFixSymbolPainter({
    required this.color,
    this.showAccent = true,
  });

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
