import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class CompleteRepairDialog extends StatefulWidget {
  const CompleteRepairDialog({
    super.key,
    required this.job,
    required this.onCompleteRepair,
  });

  final ServiceJobModel job;
  final Future<bool> Function({
    required int finalOdometer,
    DateTime? nextServiceDue,
    int? nextServiceOdometer,
    String? nextServiceType,
    String? notes,
  })
  onCompleteRepair;

  @override
  State<CompleteRepairDialog> createState() => _CompleteRepairDialogState();
}

class _CompleteRepairDialogState extends State<CompleteRepairDialog> {
  late final TextEditingController _odometerCtrl;
  late final TextEditingController _serviceTypeCtrl;
  late final TextEditingController _nextOdometerCtrl;
  late final TextEditingController _notesCtrl;
  DateTime? _nextServiceDue;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _odometerCtrl = TextEditingController(
      text: widget.job.odometerReading.toString(),
    );
    _serviceTypeCtrl = TextEditingController(text: 'Periodic Maintenance');
    _nextOdometerCtrl = TextEditingController(
      text: (widget.job.odometerReading + 5000).toString(),
    );
    _notesCtrl = TextEditingController();
    _nextServiceDue = DateTime.now().add(const Duration(days: 90));
  }

  @override
  void dispose() {
    _odometerCtrl.dispose();
    _serviceTypeCtrl.dispose();
    _nextOdometerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextServiceDue ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _nextServiceDue = picked);
    }
  }

  Future<void> _handleComplete() async {
    final odo = int.tryParse(_odometerCtrl.text.trim());
    if (odo == null || odo < 0) {
      setState(() => _error = 'Please enter a valid final odometer reading');
      return;
    }
    final nextOdo = int.tryParse(_nextOdometerCtrl.text.trim());

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await widget.onCompleteRepair(
      finalOdometer: odo,
      nextServiceDue: _nextServiceDue,
      nextServiceOdometer: nextOdo,
      nextServiceType: _serviceTypeCtrl.text.trim().isNotEmpty
          ? _serviceTypeCtrl.text.trim()
          : null,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
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
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('completeRepair'),
                          style: AppFonts.titleLarge(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Set maintenance schedule & issue digital gate pass',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppFonts.labelSmall(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppTextField(
                label: 'Final Odometer Reading (km)',
                hint: 'e.g. 45000',
                controller: _odometerCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.speed_rounded),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Next Recommended Service Type',
                hint: 'e.g. Periodic Maintenance, Oil Service',
                controller: _serviceTypeCtrl,
                prefixIcon: const Icon(Icons.build_circle_outlined),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Due Date',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: AppColors.accentBlue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _nextServiceDue != null
                                      ? DateFormatter.formatDate(
                                          _nextServiceDue!,
                                        )
                                      : 'Select date',
                                  style: AppFonts.labelMedium(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Target Odometer (km)',
                      hint: 'e.g. 50000',
                      controller: _nextOdometerCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.add_road_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Technician Handover & Maintenance Notes',
                hint:
                    'Recommended brake pad check at next service, tyre rotated',
                controller: _notesCtrl,
                maxLines: 3,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.accentBlue,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Completing repair updates the customer vehicle record, schedules the next service reminder, generates a 6-digit gate pass, and triggers delivery notifications.',
                        style: AppFonts.bodySmall(color: primaryTextColor)
                            .copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(context.tr('cancel')),
                    ),
                    AppButton(
                      label: context.loc.locale.languageCode == 'ml'
                          ? 'പൂർത്തിയാക്കുക & ഗേറ്റ് പാസ്'
                          : 'Complete & Issue Pass',
                      icon: const Icon(Icons.done_all_rounded, size: 18),
                      isLoading: _isLoading,
                      variant: AppButtonVariant.primary,
                      onPressed: _handleComplete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
