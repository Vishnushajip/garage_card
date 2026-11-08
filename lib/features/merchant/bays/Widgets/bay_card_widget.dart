import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';

import '../Model/workshop_bay_model.dart';

class BayCardWidget extends StatelessWidget {
  const BayCardWidget({
    super.key,
    required this.bay,
    required this.onAssignJob,
    required this.onReleaseBay,
    required this.onToggleMaintenance,
    required this.onDeleteBay,
    this.onViewJob,
  });

  final WorkshopBayModel bay;
  final VoidCallback onAssignJob;
  final VoidCallback onReleaseBay;
  final VoidCallback onToggleMaintenance;
  final VoidCallback onDeleteBay;
  final ValueChanged<String>? onViewJob;

  IconData _bayIcon(String type) {
    switch (type.toLowerCase()) {
      case 'twowheeler':
        return Icons.two_wheeler_rounded;
      case 'fourwheeler':
        return Icons.directions_car_rounded;
      case 'detailing':
        return Icons.local_car_wash_rounded;
      case 'quickservice':
        return Icons.speed_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'occupied':
        return AppColors.primaryRed;
      case 'maintenance':
        return AppColors.accentAmber;
      default:
        return AppColors.success;
    }
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'occupied':
        return context.tr('occupied');
      case 'maintenance':
        return context.tr('maintenance');
      default:
        return context.tr('available');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final statusColor = _statusColor(bay.status);

    return Card(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_bayIcon(bay.type), size: 20, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bay.name,
                        style: AppFonts.titleSmall(color: primaryText)
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusLabel(context, bay.status),
                          style: AppFonts.labelSmall(color: statusColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (val) {
                    if (val == 'maintenance') {
                      onToggleMaintenance();
                    } else if (val == 'delete') {
                      onDeleteBay();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'maintenance',
                      child: Row(
                        children: [
                          Icon(
                            bay.isMaintenance
                                ? Icons.check_circle_outline_rounded
                                : Icons.build_circle_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bay.isMaintenance
                                ? 'Mark Available'
                                : 'Mark Maintenance',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.primaryRed,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Bay',
                            style: TextStyle(color: AppColors.primaryRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bay.isOccupied) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sectionBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_car_rounded,
                          size: 14,
                          color: AppColors.accentBlue,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            bay.currentVehicleDisplay ?? 'Vehicle Assigned',
                            style: AppFonts.bodySmall(color: primaryText)
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 13,
                          color: secondaryText,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            bay.currentMechanic != null &&
                                    bay.currentMechanic!.isNotEmpty
                                ? 'Mechanic: ${bay.currentMechanic}'
                                : 'Assigned Mechanic',
                            style: AppFonts.labelSmall(color: secondaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (bay.currentJobId != null && onViewJob != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onViewJob!(bay.currentJobId!),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(context.tr('viewDetails')),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReleaseBay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(context.tr('releaseBay')),
                    ),
                  ),
                ],
              ),
            ] else if (bay.isAvailable) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Bay ready for next repair job',
                    style: AppFonts.labelSmall(color: AppColors.success)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: context.tr('assignJob'),
                  icon: const Icon(Icons.add_task_rounded, size: 16),
                  onPressed: onAssignJob,
                  height: 38,
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentAmber.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Under scheduled maintenance',
                    style: AppFonts.labelSmall(color: AppColors.accentAmber),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onToggleMaintenance,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Mark Available'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
