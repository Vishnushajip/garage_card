import 'package:flutter/material.dart';
import 'package:garage_card/core/localization/app_localizations.dart';

import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.status, this.customLabel});

  final String status;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    final normalized = status
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => '_${m[1]}')
        .toLowerCase()
        .replaceAll(' ', '_');

    final loc = AppLocalizations.of(context);
    final display = customLabel ?? loc.status(status);

    switch (normalized) {
      case 'completed':
      case 'approved':
      case 'paid':
        bg = AppColors.successBg;
        fg = AppColors.success;
        break;
      case 'in_progress':
      case 'received':
      case 'partially_paid':
        bg = AppColors.infoBg;
        fg = AppColors.info;
        break;
      case 'inspection_pending':
      case 'estimate_pending':
      case 'pending':
      case 'ready_for_collection':
      case 'ready':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        break;
      case 'cancelled':
      case 'rejected':
      case 'overdue':
      case 'unpaid':
        bg = AppColors.errorBg;
        fg = AppColors.error;
        break;
      case 'draft':
      default:
        bg = AppColors.borderLight;
        fg = AppColors.textSecondaryLight;
        break;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        display,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.labelSmall(color: fg).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          fontSize: 10,
        ),
      ),
    );
  }
}
