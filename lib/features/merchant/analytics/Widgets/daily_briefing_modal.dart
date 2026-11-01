import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';

class DailyBriefingModal extends StatelessWidget {
  const DailyBriefingModal({
    super.key,
    required this.todayDeliveries,
    required this.pendingDues,
    required this.yesterdayCompleted,
    required this.onDismiss,
    required this.onViewTodo,
    this.customDateTime,
  });

  final int todayDeliveries;
  final int pendingDues;
  final int yesterdayCompleted;
  final VoidCallback onDismiss;
  final VoidCallback onViewTodo;
  final DateTime? customDateTime;

  DateTime get _effectiveIndianTime {
    if (customDateTime != null) {
      return customDateTime!;
    }
    return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  int get _hour => _effectiveIndianTime.hour;

  String get greetingTitle {
    final h = _hour;
    if (h >= 5 && h < 12) {
      return 'Good Morning! Daily Garage Briefing';
    }
    if (h >= 12 && h < 17) {
      return 'Good Afternoon! Daily Garage Briefing';
    }
    if (h >= 17 && h < 21) {
      return 'Good Evening! Daily Garage Briefing';
    }
    return 'Good Night! Daily Garage Briefing';
  }

  IconData get greetingIcon {
    final h = _hour;
    if (h >= 5 && h < 12) {
      return Icons.wb_sunny_rounded;
    }
    if (h >= 12 && h < 17) {
      return Icons.sunny;
    }
    if (h >= 17 && h < 21) {
      return Icons.wb_twilight_rounded;
    }
    return Icons.bedtime_rounded;
  }

  Color _iconColor() {
    final h = _hour;
    if (h >= 5 && h < 12) {
      return AppColors.accentAmber;
    }
    if (h >= 12 && h < 17) {
      return const Color(0xFFF59E0B);
    }
    if (h >= 17 && h < 21) {
      return const Color(0xFFA855F7);
    }
    return const Color(0xFF38BDF8);
  }

  Color _titleColor(bool isDark) {
    final h = _hour;
    if (h >= 5 && h < 12) {
      return isDark ? const Color(0xFF60A5FA) : AppColors.accentBlue;
    }
    if (h >= 12 && h < 17) {
      return isDark ? const Color(0xFFFBBF24) : const Color(0xFFC2410C);
    }
    if (h >= 17 && h < 21) {
      return isDark ? const Color(0xFFA78BFA) : const Color(0xFF4F46E5);
    }
    return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);
  }

  Color _iconBackgroundColor(bool isDark) {
    final h = _hour;
    if (h >= 5 && h < 12) {
      return AppColors.accentBlue.withValues(alpha: isDark ? 0.25 : 0.15);
    }
    if (h >= 12 && h < 17) {
      return const Color(0xFFEA580C).withValues(alpha: isDark ? 0.25 : 0.15);
    }
    if (h >= 17 && h < 21) {
      return const Color(0xFF6366F1).withValues(alpha: isDark ? 0.25 : 0.15);
    }
    return const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.15);
  }

  List<Color> _gradientColors(bool isDark) {
    final h = _hour;
    if (h >= 5 && h < 12) {
      return [
        AppColors.accentBlue.withValues(alpha: isDark ? 0.20 : 0.12),
        AppColors.accentAmber.withValues(alpha: isDark ? 0.15 : 0.08),
      ];
    }
    if (h >= 12 && h < 17) {
      return [
        const Color(0xFFEA580C).withValues(alpha: isDark ? 0.18 : 0.12),
        const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.12 : 0.07),
      ];
    }
    if (h >= 17 && h < 21) {
      return [
        const Color(0xFF6366F1).withValues(alpha: isDark ? 0.20 : 0.12),
        const Color(0xFFEC4899).withValues(alpha: isDark ? 0.14 : 0.07),
      ];
    }
    return [
      const Color(0xFF0F172A).withValues(alpha: isDark ? 0.50 : 0.10),
      const Color(0xFF0284C7).withValues(alpha: isDark ? 0.20 : 0.06),
    ];
  }

  Color _borderColor(bool isDark) {
    final h = _hour;
    if (h >= 5 && h < 12) {
      return AppColors.accentBlue.withValues(alpha: isDark ? 0.35 : 0.25);
    }
    if (h >= 12 && h < 17) {
      return const Color(0xFFEA580C).withValues(alpha: isDark ? 0.35 : 0.25);
    }
    if (h >= 17 && h < 21) {
      return const Color(0xFF6366F1).withValues(alpha: isDark ? 0.35 : 0.25);
    }
    return const Color(0xFF0284C7).withValues(alpha: isDark ? 0.35 : 0.25);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final titleColor = _titleColor(isDark);
    final iconColor = _iconColor();
    final iconBgColor = _iconBackgroundColor(isDark);
    final gradientColors = _gradientColors(isDark);
    final borderColor = _borderColor(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(greetingIcon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        greetingTitle,
                        style: AppFonts.titleMedium(color: titleColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDismiss,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$todayDeliveries vehicle(s) scheduled for delivery today. $yesterdayCompleted vehicle(s) were completed yesterday. $pendingDues payment balances pending.',
                  style: AppFonts.bodyMedium(color: primaryTextColor),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: onViewTodo,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    foregroundColor: titleColor,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text('View Today\'s Delivery & Task Pipeline'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
