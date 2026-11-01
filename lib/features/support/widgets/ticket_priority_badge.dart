import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';

class TicketPriorityBadge extends StatelessWidget {
  const TicketPriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  final String priority;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (priority) {
      case 'urgent':
        color = AppColors.error;
        icon = Icons.priority_high_rounded;
        label = 'Urgent';
        break;
      case 'high':
        color = AppColors.warning;
        icon = Icons.arrow_upward_rounded;
        label = 'High';
        break;
      case 'low':
        color = Colors.grey.shade500;
        icon = Icons.arrow_downward_rounded;
        label = 'Low';
        break;
      case 'medium':
      default:
        color = AppColors.accentBlue;
        icon = Icons.remove_rounded;
        label = 'Medium';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 10 : 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppFonts.labelSmall(color: color).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }
}
