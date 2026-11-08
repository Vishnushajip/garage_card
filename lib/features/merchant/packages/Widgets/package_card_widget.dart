import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';

import '../Model/service_package_model.dart';

import 'package:garage_card/features/merchant/packages/Widgets/package_whatsapp_share_dialog.dart';

class PackageCardWidget extends StatelessWidget {
  const PackageCardWidget({
    super.key,
    required this.package,
    required this.onToggleActive,
    required this.onDelete,
  });

  final ServicePackageModel package;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  IconData _vehicleIcon() {
    switch (package.vehicleType.toLowerCase()) {
      case 'twowheeler':
        return Icons.two_wheeler_rounded;
      case 'fourwheeler':
        return Icons.directions_car_rounded;
      default:
        return Icons.directions_car_filled_rounded;
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

    return Card(
      color: cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: package.isActive
              ? borderColor
              : borderColor.withValues(alpha: 0.5),
        ),
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
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _vehicleIcon(),
                    size: 20,
                    color: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.title,
                        style: AppFonts.titleMedium(color: primaryText)
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: package.isActive
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : secondaryText.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              package.isActive ? 'Active Offer' : 'Paused',
                              style: AppFonts.labelSmall(
                                color: package.isActive
                                    ? AppColors.success
                                    : secondaryText,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${package.validityDays} days validity',
                            style: AppFonts.labelSmall(color: secondaryText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: package.isActive,
                  activeColor: AppColors.success,
                  onChanged: (_) => onToggleActive(),
                ),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (val) {
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (ctx) => [
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
                            'Delete Package',
                            style: TextStyle(color: AppColors.primaryRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (package.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                package.description,
                style: AppFonts.bodySmall(color: secondaryText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (package.includedServices.isNotEmpty) ...[
              const SizedBox(height: 12),
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
                    Text(
                      context.tr('includedTasks'),
                      style: AppFonts.labelSmall(color: secondaryText)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    ...package.includedServices.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task,
                                style: AppFonts.bodySmall(color: primaryText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(package.packagePrice),
                          style: AppFonts.titleLarge(color: AppColors.success)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (package.originalPrice > package.packagePrice) ...[
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.format(package.originalPrice),
                            style: AppFonts.bodySmall(
                              color: secondaryText,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                    if (package.savingsPercentage > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${context.tr("savings")} ${CurrencyFormatter.format(package.savingsAmount)} (${package.savingsPercentage}%)',
                          style: AppFonts.labelSmall(color: AppColors.success)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => PackageWhatsAppShareDialog.show(
                    context,
                    package: package,
                  ),
                  icon: const AppWhatsAppIcon(size: 16, color: Colors.white),
                  label: Text(context.tr('sharePromo')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
