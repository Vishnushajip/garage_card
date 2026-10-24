import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../fonts/app_fonts.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  final String status;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String display = customLabel ?? status.toUpperCase();

    final normalized = status.toLowerCase().replaceAll(' ', '_');

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        display,
        style: AppFonts.labelSmall(color: fg).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
