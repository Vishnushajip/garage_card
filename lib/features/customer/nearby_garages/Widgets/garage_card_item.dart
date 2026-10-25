import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/location/geohash_helper.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

class GarageCardItem extends StatelessWidget {
  const GarageCardItem({
    super.key,
    required this.garage,
    required this.userLat,
    required this.userLon,
    required this.onTap,
    required this.onRequestService,
  });

  final GarageModel garage;
  final double userLat;
  final double userLon;
  final VoidCallback onTap;
  final VoidCallback onRequestService;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final distanceKm = GeohashHelper.calculateDistanceKm(
      lat1: userLat,
      lon1: userLon,
      lat2: garage.latitude,
      lon2: garage.longitude,
    );

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.car_repair_rounded,
                      color: AppColors.accentBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                garage.name,
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warningBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: AppColors.accentAmber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    garage.rating.toStringAsFixed(1),
                                    style: AppFonts.labelSmall(
                                      color: AppColors.primaryDark,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          garage.address,
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${distanceKm.toStringAsFixed(1)} km away',
                                style: AppFonts.labelSmall(
                                  color: AppColors.accentBlue,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              garage.openHours,
                              style: AppFonts.labelSmall(
                                  color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  IconButton.outlined(
                    tooltip: 'Call Garage',
                    icon: const Icon(Icons.phone_rounded,
                        size: 18, color: AppColors.accentBlue),
                    onPressed: () =>
                        WhatsAppShareService.makePhoneCall(garage.phone),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: 'Chat on WhatsApp',
                    icon: const Icon(Icons.chat_rounded,
                        size: 18, color: AppColors.success),
                    onPressed: () =>
                        WhatsAppShareService.sendWhatsAppMessage(
                      phoneNumber: garage.phone,
                      message:
                          'Hello ${garage.name}, I found your garage on WeFix and would like some service information.',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: 'Directions',
                    icon: const Icon(Icons.directions_rounded,
                        size: 18, color: AppColors.info),
                    onPressed: () =>
                        WhatsAppShareService.openMapDirections(
                      latitude: garage.latitude,
                      longitude: garage.longitude,
                      label: garage.name,
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Request Service',
                    onPressed: onRequestService,
                    variant: AppButtonVariant.primary,
                    height: 38,
                    fontSize: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
