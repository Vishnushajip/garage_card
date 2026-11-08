import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:intl/intl.dart';

import '../Model/financial_metrics_model.dart';

class TimeRangeChips extends StatelessWidget {
  const TimeRangeChips({
    super.key,
    required this.selectedRange,
    this.customStart,
    this.customEnd,
    required this.onSelect,
    required this.onSelectCustomRange,
  });

  final AnalyticsTimeRange selectedRange;
  final DateTime? customStart;
  final DateTime? customEnd;
  final ValueChanged<AnalyticsTimeRange> onSelect;
  final Function(DateTime start, DateTime end) onSelectCustomRange;

  void _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 30)),
      initialDateRange: DateTimeRange(
        start: customStart ?? now.subtract(const Duration(days: 7)),
        end: customEnd ?? now,
      ),
    );

    if (picked != null) {
      onSelectCustomRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final options = [
      (AnalyticsTimeRange.today, 'Today', Icons.today_rounded),
      (
        AnalyticsTimeRange.thisWeek,
        'This Week',
        Icons.calendar_view_week_rounded,
      ),
      (
        AnalyticsTimeRange.thisMonth,
        'This Month',
        Icons.calendar_month_rounded,
      ),
      (AnalyticsTimeRange.thisYear, 'This Year', Icons.event_note_rounded),
      (AnalyticsTimeRange.custom, _customLabel, Icons.date_range_rounded),
    ];

    final currentOption = options.firstWhere(
      (opt) => opt.$1 == selectedRange,
      orElse: () => options[2],
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<AnalyticsTimeRange>(
        tooltip: 'Select date range',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        color: cardBg,
        onSelected: (val) {
          if (val == AnalyticsTimeRange.custom) {
            _pickCustomRange(context);
          } else {
            onSelect(val);
          }
        },
        itemBuilder: (context) => options.map((opt) {
          final isSelected = selectedRange == opt.$1;
          return PopupMenuItem<AnalyticsTimeRange>(
            value: opt.$1,
            child: Row(
              children: [
                Icon(
                  opt.$3,
                  size: 18,
                  color: isSelected ? AppColors.accentBlue : primaryTextColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    opt.$2,
                    style:
                        AppFonts.bodyMedium(
                          color: isSelected
                              ? AppColors.accentBlue
                              : primaryTextColor,
                        ).copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.accentBlue,
                  ),
              ],
            ),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selectedRange != AnalyticsTimeRange.thisMonth
                  ? AppColors.accentBlue
                  : borderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(currentOption.$3, size: 18, color: AppColors.accentBlue),
              const SizedBox(width: 8),
              Text(
                currentOption.$2,
                style: AppFonts.labelLarge(color: primaryTextColor)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
                color: primaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _customLabel {
    if (customStart != null && customEnd != null) {
      final df = DateFormat('dd MMM');
      return '${df.format(customStart!)} - ${df.format(customEnd!)}';
    }
    return 'Custom';
  }
}
