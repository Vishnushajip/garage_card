import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';
import 'package:intl/intl.dart';

import '../Model/service_recall_model.dart';
import 'recall_whatsapp_share_dialog.dart';

class RecallVehicleCard extends StatelessWidget {
  const RecallVehicleCard({super.key, required this.item});

  final ServiceRecallItem item;

  Color _statusColor() {
    if (item.isOverdue) return AppColors.primaryRed;
    if (item.isDueThisMonth) return AppColors.accentAmber;
    return AppColors.accentBlue;
  }

  String _statusLabel(BuildContext context) {
    if (item.isOverdue) return context.tr('overdue');
    if (item.isDueThisMonth) return context.tr('dueThisMonth');
    return context.tr('upcomingService');
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

    final statusColor = _statusColor();
    final formattedDate = DateFormat('dd MMM yyyy')
        .format(item.lastServiceDate);

    return Card(
      color: cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
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
                  child: Icon(
                    Icons.two_wheeler_rounded,
                    size: 20,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.vehicleDisplay,
                        style: AppFonts.titleSmall(color: primaryText)
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.customerName}${item.customerPhone.isNotEmpty ? " • ${item.customerPhone}" : ""}',
                        style: AppFonts.labelSmall(color: secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(context),
                    style: AppFonts.labelSmall(color: statusColor)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('lastServiceDate'),
                          style: AppFonts.labelSmall(color: secondaryText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: AppFonts.bodySmall(color: primaryText)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: borderColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Elapsed',
                          style: AppFonts.labelSmall(color: secondaryText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.daysSinceLastService} ${context.tr("daysAgo")}',
                          style: AppFonts.bodySmall(color: statusColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth >= 480;
                final button = ElevatedButton.icon(
                  onPressed: () =>
                      RecallWhatsAppShareDialog.show(context, item: item),
                  icon: const AppWhatsAppIcon(size: 16, color: Colors.white),
                  label: Text(context.tr('sendRecallWhatsApp')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );

                if (isWide) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 160,
                          maxWidth: 240,
                        ),
                        child: button,
                      ),
                    ],
                  );
                }

                return SizedBox(width: double.infinity, child: button);
              },
            ),
          ],
        ),
      ),
    );
  }
}
