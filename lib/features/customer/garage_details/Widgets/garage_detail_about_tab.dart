import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_button.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/working_hours_model.dart';
import 'package:url_launcher/url_launcher.dart';

class GarageDetailAboutTab extends StatelessWidget {
  const GarageDetailAboutTab({super.key, required this.garage});

  final GarageModel garage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (garage.description.isNotEmpty) ...[
          Text('About Garage', style: AppFonts.titleMedium(color: primaryText)),
          const SizedBox(height: 6),
          Text(
            garage.description,
            style: AppFonts.bodyMedium(color: secondaryText),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'Operating Hours & Contact',
          style: AppFonts.titleMedium(color: primaryText),
        ),
        const SizedBox(height: 12),
        if (garage.dailyWorkingHours != null &&
            garage.dailyWorkingHours!.isNotEmpty) ...[
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(left: 36, bottom: 8),
              leading: const Icon(
                Icons.access_time_rounded,
                color: AppColors.primaryRed,
              ),
              title: Text(
                garage.openHours,
                style: AppFonts.bodyMedium(color: primaryText),
              ),
              subtitle: Text(
                'Weekly business hours',
                style: AppFonts.bodySmall(color: secondaryText),
              ),
              children:
                  WorkingHoursSchedule.parse(
                    garage.dailyWorkingHours,
                    garage.openHours,
                  ).map((day) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            day.dayLabel,
                            style: AppFonts.labelSmall(color: primaryText)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            day.isOpen
                                ? '${day.openTime} - ${day.closeTime}'
                                : 'Closed',
                            style: AppFonts.labelSmall(
                              color: day.isOpen
                                  ? secondaryText
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ] else ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.access_time_rounded,
              color: AppColors.primaryRed,
            ),
            title: Text(
              garage.openHours,
              style: AppFonts.bodyMedium(color: primaryText),
            ),
            subtitle: Text(
              'Opening hours',
              style: AppFonts.bodySmall(color: secondaryText),
            ),
          ),
        ],
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.location_on_rounded,
            color: AppColors.primaryRed,
          ),
          title: Text(
            garage.address.isNotEmpty
                ? garage.address
                : (garage.googleAddress ?? 'Workshop Location'),
            style: AppFonts.bodyMedium(color: primaryText),
          ),
          subtitle: Text(
            garage.googleAddress != null &&
                    garage.googleAddress!.isNotEmpty &&
                    garage.googleAddress != garage.address
                ? garage.googleAddress!
                : 'Physical address',
            style: AppFonts.bodySmall(color: secondaryText),
          ),
          trailing: (garage.latitude != 0.0 && garage.longitude != 0.0)
              ? IconButton(
                  icon: const Icon(
                    Icons.directions_rounded,
                    color: AppColors.primaryRed,
                  ),
                  tooltip: 'Get Directions',
                  onPressed: () async {
                    final url =
                        garage.googleMapsUrl != null &&
                            garage.googleMapsUrl!.isNotEmpty
                        ? garage.googleMapsUrl!
                        : 'https://www.google.com/maps/search/?api=1&query=${garage.latitude},${garage.longitude}';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                )
              : null,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.phone_rounded, color: AppColors.primaryRed),
          title: Text(
            garage.phone,
            style: AppFonts.bodyMedium(color: primaryText),
          ),
          subtitle: Text(
            'Direct phone',
            style: AppFonts.bodySmall(color: secondaryText),
          ),
        ),
        if (garage.taxNumber.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.badge_rounded,
              color: AppColors.primaryRed,
            ),
            title: Text(
              garage.taxNumber,
              style: AppFonts.bodyMedium(color: primaryText),
            ),
            subtitle: Text(
              'GST / Tax Registration',
              style: AppFonts.bodySmall(color: secondaryText),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          'On-Site & Emergency Services',
          style: AppFonts.titleMedium(color: primaryText),
        ),
        const SizedBox(height: 12),
        Card(
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (garage.isRoadsideAssistanceAvailable as bool? ??
                                true)
                            ? AppColors.errorBg
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.emergency_rounded,
                        color:
                            (garage.isRoadsideAssistanceAvailable as bool? ??
                                true)
                            ? AppColors.error
                            : AppColors.textSecondaryLight,
                        size: 24,
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
                                  'On-Road Breakdown Assistance',
                                  style: AppFonts.titleSmall(
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              AppStatusBadge(
                                status:
                                    (garage.isRoadsideAssistanceAvailable
                                            as bool? ??
                                        true)
                                    ? 'approved'
                                    : 'rejected',
                                customLabel:
                                    (garage.isRoadsideAssistanceAvailable
                                            as bool? ??
                                        true)
                                    ? 'AVAILABLE'
                                    : 'UNAVAILABLE',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (garage.isRoadsideAssistanceAvailable as bool? ??
                                    true)
                                ? 'Mechanics travel directly to your on-road vehicle breakdown spot for emergency fixes.'
                                : 'Roadside emergency dispatch is currently unavailable for this garage.',
                            style: AppFonts.bodySmall(color: secondaryText),
                          ),
                          if (garage.isRoadsideAssistanceAvailable as bool? ??
                              true) ...[
                            const SizedBox(height: 12),
                            AppWhatsAppButton(
                              phoneNumber: garage.phone,
                              label: 'Request On-Road Help (WhatsApp)',
                              isFullWidth: true,
                              message: 'SOS: My vehicle is broken down on the road. Please let me know if a mechanic can reach my location.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (garage.isDoorstepRepairAvailable as bool? ?? true)
                            ? AppColors.successBg
                            : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.home_repair_service_rounded,
                        color:
                            (garage.isDoorstepRepairAvailable as bool? ?? true)
                            ? AppColors.success
                            : AppColors.textSecondaryLight,
                        size: 24,
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
                                  'Doorstep Service / Pickup',
                                  style: AppFonts.titleSmall(
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              AppStatusBadge(
                                status:
                                    (garage.isDoorstepRepairAvailable
                                            as bool? ??
                                        true)
                                    ? 'approved'
                                    : 'rejected',
                                customLabel:
                                    (garage.isDoorstepRepairAvailable
                                            as bool? ??
                                        true)
                                    ? 'AVAILABLE'
                                    : 'UNAVAILABLE',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (garage.isDoorstepRepairAvailable as bool? ?? true)
                                ? 'Mechanics visit your doorstep or pick up your vehicle from home/office.'
                                : 'Doorstep repair and vehicle pickup are not offered by this workshop.',
                            style: AppFonts.bodySmall(color: secondaryText),
                          ),
                          if (garage.isDoorstepRepairAvailable as bool? ??
                              true) ...[
                            const SizedBox(height: 12),
                            AppWhatsAppButton(
                              phoneNumber: garage.phone,
                              label: 'Book Doorstep Service (WhatsApp)',
                              variant: WhatsAppButtonVariant.outline,
                              isFullWidth: true,
                              message:
                                  'Hello ${garage.name}, I would like to enquire about doorstep repair/pickup for my vehicle.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
