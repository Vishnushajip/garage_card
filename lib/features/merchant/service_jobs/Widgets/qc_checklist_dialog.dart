import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/qc_checklist_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

class QCChecklistDialog extends StatefulWidget {
  const QCChecklistDialog({super.key, required this.job, required this.onSave});

  final ServiceJobModel job;
  final Future<bool> Function(Map<String, bool> checklist, String inspectorName)
  onSave;

  @override
  State<QCChecklistDialog> createState() => _QCChecklistDialogState();
}

class _QCChecklistDialogState extends State<QCChecklistDialog> {
  late Map<String, bool> _checklist;
  late final TextEditingController _inspectorCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checklist = Map<String, bool>.from(widget.job.qcChecklist);
    for (final item in QCChecklistModel.standardChecklistItems) {
      _checklist.putIfAbsent(item, () => false);
    }
    _inspectorCtrl = TextEditingController(
      text: widget.job.qcInspectorName?.isNotEmpty == true
          ? widget.job.qcInspectorName!
          : (widget.job.technicianName.isNotEmpty
                ? widget.job.technicianName
                : 'Lead Inspector'),
    );
  }

  @override
  void dispose() {
    _inspectorCtrl.dispose();
    super.dispose();
  }

  void _toggleAll(bool value) {
    setState(() {
      for (final key in QCChecklistModel.standardChecklistItems) {
        _checklist[key] = value;
      }
    });
  }

  Future<void> _submit() async {
    final name = _inspectorCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter inspector name.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final success = await widget.onSave(_checklist, name);
    if (mounted) {
      setState(() => _isSaving = false);
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
    final dialogBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final passed = QCChecklistModel.passedCount(_checklist);
    final total = QCChecklistModel.totalCount(_checklist);
    final progress = QCChecklistModel.progress(_checklist);
    final isAllPassed = QCChecklistModel.isAllPassed(_checklist);

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                (isAllPassed
                                        ? AppColors.success
                                        : AppColors.accentBlue)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isAllPassed
                                ? Icons.verified_rounded
                                : Icons.checklist_rtl_rounded,
                            color: isAllPassed
                                ? AppColors.success
                                : AppColors.accentBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '9-Point QC Checklist',
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.job.vehicleDisplay,
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Inspection Progress: $passed / $total Passed',
                          style: AppFonts.labelMedium(
                            color: isAllPassed
                                ? AppColors.success
                                : primaryTextColor,
                          ).copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _toggleAll(!isAllPassed),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(
                          isAllPassed ? 'Clear All' : 'Mark All Passed',
                          style: AppFonts.labelSmall(
                            color: AppColors.accentBlue,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAllPassed ? AppColors.success : AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: QCChecklistModel.standardChecklistItems.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final key = QCChecklistModel.standardChecklistItems[i];
                  final val = _checklist[key] == true;
                  return CheckboxListTile(
                    value: val,
                    activeColor: AppColors.success,
                    title: Text(
                      key,
                      style:
                          AppFonts.bodyMedium(
                            color: val ? primaryTextColor : secondaryTextColor,
                          ).copyWith(
                            fontWeight: val
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                    onChanged: (newVal) {
                      setState(() {
                        _checklist[key] = newVal ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppTextField(
                    controller: _inspectorCtrl,
                    label: 'Inspector / Foreman Sign-off Name',
                    hint: 'e.g. Vineeth Roy (Lead Technician)',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondaryLight,
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: isAllPassed
                              ? 'Sign-off QC'
                              : 'Save Incomplete',
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isAllPassed
                                      ? Icons.verified_rounded
                                      : Icons.save_rounded,
                                  size: 18,
                                ),
                          variant: isAllPassed
                              ? AppButtonVariant.primary
                              : AppButtonVariant.secondary,
                          onPressed: _isSaving ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
