import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/features/shared/models/working_hours_model.dart';

class WorkingHoursSelector extends StatefulWidget {
  const WorkingHoursSelector({
    super.key,
    required this.schedule,
    required this.onChanged,
  });

  final List<DayWorkingHours> schedule;
  final ValueChanged<List<DayWorkingHours>> onChanged;

  @override
  State<WorkingHoursSelector> createState() => _WorkingHoursSelectorState();
}

class _WorkingHoursSelectorState extends State<WorkingHoursSelector> {
  late List<DayWorkingHours> _currentSchedule;

  @override
  void initState() {
    super.initState();
    _currentSchedule = widget.schedule.isNotEmpty
        ? List<DayWorkingHours>.from(widget.schedule)
        : WorkingHoursSchedule.defaultSchedule();
  }

  @override
  void didUpdateWidget(covariant WorkingHoursSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.schedule != oldWidget.schedule && widget.schedule.isNotEmpty) {
      _currentSchedule = List<DayWorkingHours>.from(widget.schedule);
    }
  }

  void _updateDay(int index, DayWorkingHours updated) {
    final next = List<DayWorkingHours>.from(_currentSchedule);
    next[index] = updated;
    setState(() => _currentSchedule = next);
    widget.onChanged(next);
  }

  void _applyMonSatPreset() {
    final next = _currentSchedule.map((d) {
      if (d.day == 'sunday') {
        return d.copyWith(isOpen: false);
      }
      return d.copyWith(
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      );
    }).toList();
    setState(() => _currentSchedule = next);
    widget.onChanged(next);
  }

  void _applyMonFriPreset() {
    final next = _currentSchedule.map((d) {
      if (d.day == 'saturday' || d.day == 'sunday') {
        return d.copyWith(isOpen: false);
      }
      return d.copyWith(
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      );
    }).toList();
    setState(() => _currentSchedule = next);
    widget.onChanged(next);
  }

  void _applyAllDaysPreset() {
    final next = _currentSchedule.map((d) {
      return d.copyWith(
        isOpen: true,
        openTime: '08:30 AM',
        closeTime: '07:30 PM',
      );
    }).toList();
    setState(() => _currentSchedule = next);
    widget.onChanged(next);
  }

  void _apply24HoursPreset() {
    final next = _currentSchedule.map((d) {
      return d.copyWith(
        isOpen: true,
        openTime: '12:00 AM',
        closeTime: '11:59 PM',
      );
    }).toList();
    setState(() => _currentSchedule = next);
    widget.onChanged(next);
  }

  void _copyDayHoursToAll(DayWorkingHours sourceDay) {
    final next = _currentSchedule.map((d) {
      if (!d.isOpen) return d;
      return d.copyWith(
        openTime: sourceDay.openTime,
        closeTime: sourceDay.closeTime,
      );
    }).toList();
    setState(() => _currentSchedule = next);
    widget.onChanged(next);
    AppNotificationService.info(
      'Copied ${sourceDay.dayLabel}\'s hours to all open days',
      duration: const Duration(seconds: 2),
    );
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final normalized = timeStr.trim().toUpperCase();
      final isPM = normalized.contains('PM');
      final isAM = normalized.contains('AM');

      final cleaned = normalized
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim();
      final parts = cleaned.split(':');
      if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 30);

      var hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());

      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 30);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = hour.toString().padLeft(2, '0');
    return '$hourStr:$minute $period';
  }

  Future<void> _pickTime({
    required BuildContext context,
    required bool isStart,
    required int index,
    required DayWorkingHours day,
  }) async {
    final initial = _parseTimeOfDay(isStart ? day.openTime : day.closeTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryRed,
                    surface: AppColors.surfaceDark,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primaryRed,
                    surface: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = _formatTimeOfDay(picked);
      final updated = isStart
          ? day.copyWith(openTime: formatted)
          : day.copyWith(closeTime: formatted);
      _updateDay(index, updated);
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
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final summary = WorkingHoursSchedule.toDisplaySummary(_currentSchedule);
    final isOpenNow = WorkingHoursSchedule.isCurrentlyOpen(_currentSchedule);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            size: 20,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('workingHours'),
                              style: AppFonts.titleMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'WhatsApp Business Schedule',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOpenNow
                            ? AppColors.successBg
                            : AppColors.errorBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOpenNow
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOpenNow
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOpenNow ? 'Open Now' : 'Closed',
                            style: AppFonts.labelSmall(
                              color: isOpenNow
                                  ? AppColors.success
                                  : AppColors.error,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.accentBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary,
                          style: AppFonts.bodySmall(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Quick Presets:',
                  style: AppFonts.labelSmall(color: secondaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildPresetChip('Mon - Sat', _applyMonSatPreset),
                    _buildPresetChip('Mon - Fri', _applyMonFriPreset),
                    _buildPresetChip('All 7 Days', _applyAllDaysPreset),
                    _buildPresetChip('24/7 Always Open', _apply24HoursPreset),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentSchedule.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: borderColor.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final day = _currentSchedule[index];
              return _buildDayRow(
                context,
                index: index,
                day: day,
                isDark: isDark,
                borderColor: borderColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.accentBlue.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: AppFonts.labelSmall(color: AppColors.accentBlue)
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDayRow(
    BuildContext context, {
    required int index,
    required DayWorkingHours day,
    required bool isDark,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: day.isOpen
                          ? AppColors.primaryRed.withValues(alpha: 0.14)
                          : (isDark
                                ? AppColors.backgroundDark
                                : AppColors.backgroundLight),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: day.isOpen
                            ? AppColors.primaryRed.withValues(alpha: 0.3)
                            : borderColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day.shortDayLabel,
                        style: AppFonts.labelSmall(
                          color: day.isOpen
                              ? AppColors.primaryRed
                              : secondaryTextColor,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(day.day),
                        style: AppFonts.titleSmall(color: primaryTextColor)
                            .copyWith(
                              fontWeight: day.isOpen
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                      ),
                      Text(
                        day.isOpen
                            ? '${day.openTime} - ${day.closeTime}'
                            : 'Closed for the day',
                        style: AppFonts.labelSmall(
                          color: day.isOpen
                              ? secondaryTextColor
                              : AppColors.textMutedDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: day.isOpen,
                activeColor: AppColors.primaryRed,
                onChanged: (val) {
                  _updateDay(index, day.copyWith(isOpen: val));
                },
              ),
            ],
          ),
          if (day.isOpen) ...[
            const SizedBox(height: 10),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTimeButton(
                  context: context,
                  label: 'Opens at',
                  time: day.openTime,
                  isDark: isDark,
                  borderColor: borderColor,
                  primaryTextColor: primaryTextColor,
                  onTap: () => _pickTime(
                    context: context,
                    isStart: true,
                    index: index,
                    day: day,
                  ),
                ),
                Text(
                  'to',
                  style: AppFonts.labelSmall(color: secondaryTextColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                _buildTimeButton(
                  context: context,
                  label: 'Closes at',
                  time: day.closeTime,
                  isDark: isDark,
                  borderColor: borderColor,
                  primaryTextColor: primaryTextColor,
                  onTap: () => _pickTime(
                    context: context,
                    isStart: false,
                    index: index,
                    day: day,
                  ),
                ),
                IconButton(
                  tooltip: 'Copy this schedule to all open days',
                  icon: const Icon(
                    Icons.copy_all_rounded,
                    size: 18,
                    color: AppColors.accentBlue,
                  ),
                  onPressed: () => _copyDayHoursToAll(day),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeButton({
    required BuildContext context,
    required String label,
    required String time,
    required bool isDark,
    required Color borderColor,
    required Color primaryTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: AppColors.primaryRed,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppFonts.labelSmall(color: AppColors.textMutedDark)
                      .copyWith(fontSize: 10),
                ),
                Text(
                  time,
                  style: AppFonts.bodySmall(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: AppColors.textMutedDark,
            ),
          ],
        ),
      ),
    );
  }
}
