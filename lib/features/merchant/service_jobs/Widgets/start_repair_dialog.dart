import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class StartRepairDialog extends StatefulWidget {
  const StartRepairDialog({
    super.key,
    required this.job,
    required this.onStartRepair,
  });

  final ServiceJobModel job;
  final Future<bool> Function(String? technicianName, String? notes)
  onStartRepair;

  @override
  State<StartRepairDialog> createState() => _StartRepairDialogState();
}

class _StartRepairDialogState extends State<StartRepairDialog> {
  late final TextEditingController _technicianCtrl;
  late final TextEditingController _notesCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _technicianCtrl = TextEditingController(text: widget.job.technicianName);
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _technicianCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    setState(() => _isLoading = true);
    final success = await widget.onStartRepair(
      _technicianCtrl.text.trim().isNotEmpty
          ? _technicianCtrl.text.trim()
          : null,
      _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
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

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.accentBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.locale.languageCode == 'ml'
                              ? 'റിപ്പയർ ആരംഭിക്കുക'
                              : 'Start Repair Work',
                          style: AppFonts.titleLarge(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.job.jobNumber,
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.accentBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.job.vehicleDisplay,
                        style: AppFonts.labelMedium(color: primaryTextColor)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Assigned Lead Technician',
                hint: 'e.g. Ramesh Kumar',
                controller: _technicianCtrl,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Repair Commencement Notes',
                hint: 'e.g. Disassembly started, preliminary checks underway',
                controller: _notesCtrl,
                maxLines: 3,
                prefixIcon: const Icon(Icons.note_alt_outlined),
              ),
              const SizedBox(height: 12),
              Text(
                'Starting repair transitions status to "In Progress" and immediately dispatches a real-time tracking update to the customer.',
                style: AppFonts.bodySmall(
                  color: secondaryTextColor.withValues(alpha: 0.8),
                ).copyWith(fontSize: 11),
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
                          ? 'പണി ആരംഭിക്കുക'
                          : 'Commence Work',
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      isLoading: _isLoading,
                      variant: AppButtonVariant.primary,
                      onPressed: _handleStart,
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
