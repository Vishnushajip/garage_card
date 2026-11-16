import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'clay_container.dart';
import 'clay_tooltip.dart';

class ClayMajorKpiCard extends StatelessWidget {
  const ClayMajorKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconBgColor = const Color(0xFFDCFCE7),
    this.iconColor = const Color(0xFF16A34A),
    this.subtitle,
    this.trendPercent,
    this.tooltipMessage,
    this.onTap,
  });

  final String title;
  final String value;
  final PhosphorIconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? subtitle;
  final double? trendPercent;
  final String? tooltipMessage;
  final VoidCallback? onTap;

  Widget _buildTrendChip(double percent, bool isDark) {
    final isPositive = percent > 0;
    final isZero = percent == 0;

    final Color chipBg = isZero
        ? (isDark ? Colors.white10 : const Color(0xFFF1F5F9))
        : (isPositive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2));
    final Color textColor = isZero
        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
        : (isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626));
    final PhosphorIconData trendIcon = isZero
        ? PhosphorIconsRegular.minus
        : (isPositive
              ? PhosphorIconsBold.trendUp
              : PhosphorIconsBold.trendDown);

    final formatted = percent.abs().toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2), width: 0.8),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? iconColor.withValues(alpha: 0.2)
                      : iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PhosphorIcon(icon, size: 18, color: iconColor),
                ),
              ),
              if (trendPercent != null)
                _buildTrendChip(trendPercent!, isDark)
              else if (tooltipMessage != null)
                ClayTooltip(message: tooltipMessage!, iconSize: 13),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: AppFonts.labelSmall(color: secondaryTextColor).copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              if (tooltipMessage != null && trendPercent != null) ...[
                const SizedBox(width: 4),
                ClayTooltip(message: tooltipMessage!, iconSize: 11),
              ],
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppFonts.displaySmall(color: primaryTextColor).copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppFonts.labelSmall(
                color: secondaryTextColor.withValues(alpha: 0.8),
              ).copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class ClaySubKpiCard extends StatelessWidget {
  const ClaySubKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primaryRed,
    this.subtitle,
    this.tooltipMessage,
    this.onTap,
  });

  final String title;
  final String value;
  final PhosphorIconData icon;
  final Color iconColor;
  final String? subtitle;
  final String? tooltipMessage;
  final VoidCallback? onTap;

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
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PhosphorIcon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppFonts.labelMedium(
                          color: primaryTextColor,
                        ).copyWith(fontSize: 11.5, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tooltipMessage != null) ...[
                      const SizedBox(width: 4),
                      ClayTooltip(message: tooltipMessage!, iconSize: 10),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppFonts.labelSmall(color: secondaryTextColor)
                        .copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: AppFonts.titleMedium(color: primaryTextColor)
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return ClayMajorKpiCard(
      title: title,
      value: value,
      icon: icon,
      iconColor: accentColor,
      iconBgColor: accentColor.withValues(alpha: 0.14),
      subtitle: subtitle,
      trendPercent: trendPercent,
      tooltipMessage: tooltipMessage,
      onTap: onTap,
    );
  }
}
