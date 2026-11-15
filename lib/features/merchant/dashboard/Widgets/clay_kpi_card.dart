import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'clay_container.dart';
import 'clay_tooltip.dart';

class ClayKpiCard extends StatelessWidget {
  const ClayKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor = AppColors.accentBlue,
    this.subtitle,
    this.trendPercent,
    this.tooltipMessage,
    this.onTap,
  });

  final String title;
  final String value;
  final PhosphorIconData icon;
  final Color accentColor;
  final String? subtitle;
  final double? trendPercent;
  final String? tooltipMessage;
  final VoidCallback? onTap;

  Widget _buildTrendChip(double percent, bool isDark) {
    final isPositive = percent > 0;
    final isZero = percent == 0;

    final Color chipBg;
    final Color textColor;
    final PhosphorIconData trendIcon;

    if (isZero) {
      chipBg = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFF1F5F9);
      textColor = isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;
      trendIcon = PhosphorIconsRegular.minus;
    } else if (isPositive) {
      chipBg = AppColors.success.withValues(alpha: isDark ? 0.16 : 0.12);
      textColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
      trendIcon = PhosphorIconsBold.trendUp;
    } else {
      chipBg = AppColors.error.withValues(alpha: isDark ? 0.16 : 0.12);
      textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      trendIcon = PhosphorIconsBold.trendDown;
    }

    final formatted = percent.abs().toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(trendIcon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            isZero ? '0.0%' : '${isPositive ? '+' : '-'}$formatted%',
            style: AppFonts.labelSmall(color: textColor)
                .copyWith(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return ClayContainer(
      onTap: onTap,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.16 : 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.28 : 0.18),
                width: 1.2,
              ),
            ),
            child: Center(
              child: PhosphorIcon(icon, size: 20, color: accentColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppFonts.labelSmall(color: secondaryTextColor)
                            .copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trendPercent != null) ...[
                      const SizedBox(width: 6),
                      _buildTrendChip(trendPercent!, isDark),
                    ],
                    if (tooltipMessage != null) ...[
                      const SizedBox(width: 4),
                      ClayTooltip(message: tooltipMessage!, iconSize: 12),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppFonts.titleLarge(color: primaryTextColor).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: AppFonts.labelSmall(
                      color: secondaryTextColor.withValues(alpha: 0.8),
                    ).copyWith(fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
