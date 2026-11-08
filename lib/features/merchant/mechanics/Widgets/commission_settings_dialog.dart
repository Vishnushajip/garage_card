import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';

class CommissionSettingsDialog extends StatefulWidget {
  const CommissionSettingsDialog({
    super.key,
    required this.currentRate,
    required this.onSave,
  });

  final double currentRate;
  final ValueChanged<double> onSave;

  static Future<void> show(
    BuildContext context, {
    required double currentRate,
    required ValueChanged<double> onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) =>
          CommissionSettingsDialog(currentRate: currentRate, onSave: onSave),
    );
  }

  @override
  State<CommissionSettingsDialog> createState() =>
      _CommissionSettingsDialogState();
}

class _CommissionSettingsDialogState extends State<CommissionSettingsDialog> {
  late final TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(
      text: widget.currentRate.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = double.tryParse(_rateController.text.trim());
    if (parsed != null && parsed >= 0 && parsed <= 100) {
      widget.onSave(parsed);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return AlertDialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.percent_rounded, color: AppColors.accentBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr('commissionRate'),
              style: AppFonts.titleMedium(color: primaryTextColor),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: context.tr('commissionRate'),
            hint: 'e.g. 10 or 15',
            controller: _rateController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.calculate_outlined),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        SizedBox(
          width: 110,
          child: AppButton(
            label: context.tr('save'),
            onPressed: _submit,
            height: 38,
          ),
        ),
      ],
    );
  }
}
