import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../Model/dashboard_analytics_models.dart';
import 'clay_container.dart';

class SmartAlertsBanner extends StatelessWidget {
  const SmartAlertsBanner({super.key, required this.alerts});

  final List<DashboardSmartAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: alerts.map((alert) {
        final Color accentColor;
        final PhosphorIconData icon;

        switch (alert.severity) {
          case SmartAlertSeverity.danger:
            accentColor = AppColors.error;
            icon = PhosphorIconsFill.warningOctagon;
            break;
          case SmartAlertSeverity.warning:
            accentColor = AppColors.accentAmber;
            icon = PhosphorIconsFill.warning;
            break;
          case SmartAlertSeverity.info:
            accentColor = AppColors.accentBlue;
            icon = PhosphorIconsFill.info;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClayContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            borderColor: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
            color: isDark
                ? Color.alphaBlend(
                    accentColor.withValues(alpha: 0.08),
                    const Color(0xFF141923),
                  )
                : Color.alphaBlend(
                    accentColor.withValues(alpha: 0.04),
                    const Color(0xFFFAFBFD),
                  ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.18 : 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: PhosphorIcon(icon, color: accentColor, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: AppFonts.titleSmall(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        alert.message,
                        style: AppFonts.bodySmall(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => context.push(alert.actionRoute),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    alert.actionLabel,
                    style: AppFonts.labelSmall(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
