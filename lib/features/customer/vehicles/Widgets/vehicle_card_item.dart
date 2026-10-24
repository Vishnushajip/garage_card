import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';

class VehicleCardItem extends StatelessWidget {
  const VehicleCardItem({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  final VehicleModel vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.accentBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                      style: AppFonts.titleMedium(color: primaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.borderLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            vehicle.licensePlate,
                            style: AppFonts.labelSmall(
                              color: primaryTextColor,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${vehicle.currentOdometer} km • ${vehicle.fuelType}',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                      ],
                    ),
                    if (vehicle.nextServiceDue != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Next Service: ${DateFormatter.formatDate(vehicle.nextServiceDue)}',
                        style: AppFonts.labelSmall(color: AppColors.accentBlue),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.accentBlue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
