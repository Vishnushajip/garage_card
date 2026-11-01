import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';

class TicketStatusBadge extends StatelessWidget {
  const TicketStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  final String status;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String labelKey;

    switch (status) {
      case 'in_progress':
      case 'assigned':
        bg = AppColors.accentBlue.withValues(alpha: 0.12);
        fg = AppColors.accentBlue;
        labelKey = 'inProgress';
        break;
      case 'waiting_for_customer':
        bg = AppColors.warning.withValues(alpha: 0.12);
        fg = AppColors.warning;
        labelKey = 'waitingCustomer';
        break;
      case 'waiting_for_merchant':
        bg = AppColors.primaryRed.withValues(alpha: 0.12);
        fg = AppColors.primaryRed;
        labelKey = 'waitingMerchant';
        break;
      case 'resolved':
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        labelKey = 'resolved';
        break;
      case 'closed':
        bg = Colors.grey.withValues(alpha: 0.16);
        fg = Colors.grey.shade600;
        labelKey = 'closed';
        break;
      case 'reopened':
        bg = Colors.purple.withValues(alpha: 0.12);
        fg = Colors.purple;
        labelKey = 'reopened';
        break;
      case 'open':
      default:
        bg = AppColors.primaryRed.withValues(alpha: 0.12);
        fg = AppColors.primaryRed;
        labelKey = 'open';
        break;
    }

    final displayText = context.tr(labelKey);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        displayText,
        style: AppFonts.labelSmall(
          color: fg,
        ).copyWith(fontWeight: FontWeight.bold, fontSize: isCompact ? 10 : 11),
      ),
    );
  }
}
