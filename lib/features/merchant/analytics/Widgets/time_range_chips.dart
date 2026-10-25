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

    final options = [
      (AnalyticsTimeRange.today, 'Today'),
      (AnalyticsTimeRange.thisWeek, 'This Week'),
      (AnalyticsTimeRange.thisMonth, 'This Month'),
      (AnalyticsTimeRange.thisYear, 'This Year'),
      (AnalyticsTimeRange.custom, _customLabel),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = selectedRange == opt.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                opt.$2,
                style: AppFonts.labelLarge(
                  color: isSelected
                      ? Colors.white
                      : isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.accentBlue,
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              side: BorderSide(
                color: isSelected
                    ? AppColors.accentBlue
                    : isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
              onSelected: (val) {
                if (opt.$1 == AnalyticsTimeRange.custom) {
                  _pickCustomRange(context);
                } else {
                  onSelect(opt.$1);
                }
              },
            ),
          );
        }).toList(),
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
