import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';

class TicketResolutionDialog extends StatefulWidget {
  const TicketResolutionDialog({
    super.key,
    required this.ticketNumber,
    this.isReopen = false,
  });

  final String ticketNumber;
  final bool isReopen;

  static Future<String?> show(
    BuildContext context, {
    required String ticketNumber,
    bool isReopen = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => TicketResolutionDialog(
        ticketNumber: ticketNumber,
        isReopen: isReopen,
      ),
    );
  }

  @override
  State<TicketResolutionDialog> createState() => _TicketResolutionDialogState();
}

class _TicketResolutionDialogState extends State<TicketResolutionDialog> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

    final title = widget.isReopen
        ? context.tr('reopenTicket')
        : context.tr('resolveTicket');
    final description = widget.isReopen
        ? 'Please explain why you need to reopen ticket ${widget.ticketNumber}.'
        : 'Add resolution details or actions taken for ticket ${widget.ticketNumber}.';

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppFonts.titleLarge(color: primaryTextColor)),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppFonts.bodySmall(color: secondaryTextColor),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _commentController,
              label: widget.isReopen
                  ? context.tr('reopenReason')
                  : context.tr('resolutionNote'),
              hint: widget.isReopen
                  ? 'Enter reason for reopening...'
                  : 'Describe resolution steps...',
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: context.tr('cancel'),
                  variant: AppButtonVariant.secondary,
                  height: 40,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: widget.isReopen
                      ? context.tr('reopen')
                      : context.tr('confirmResolve'),
                  height: 40,
                  onPressed: () {
                    Navigator.of(context).pop(_commentController.text.trim());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
