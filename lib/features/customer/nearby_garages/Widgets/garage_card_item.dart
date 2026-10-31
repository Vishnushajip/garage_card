import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/location/geohash_helper.dart';
import 'package:garage_card/features/customer/inquiry/customer_inquiry_service.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

class GarageCardItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final distanceKm = GeohashHelper.calculateDistanceKm(
      lat1: userLat,
      lon1: userLon,
      lat2: garage.latitude,
      lon2: garage.longitude,
    );

    final hasCover =
        garage.coverImageUrl != null && garage.coverImageUrl!.isNotEmpty;
    final hasLogo = garage.logoUrl != null && garage.logoUrl!.isNotEmpty;

    final featuredPackageTitle = garage.servicesOffered.isNotEmpty
        ? garage.servicesOffered.first
        : 'Comprehensive Periodic Maintenance';

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasCover)
              AspectRatio(
                aspectRatio: 2.2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      garage.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.car_repair_rounded,
                            size: 40,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
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
                              '${garage.rating.toStringAsFixed(1)} (${garage.reviewCount})',
                              style: AppFonts.labelSmall(color: Colors.white)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 14,
                      right: 14,
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceDark,
                              border: Border.all(color: Colors.white, width: 2),
                              image: hasLogo
                                  ? DecorationImage(
                                      image: NetworkImage(garage.logoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: !hasLogo
                                ? const Icon(
                                    Icons.garage_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        garage.name,
                                        style: AppFonts.titleMedium(
                                          color: Colors.white,
                                        ).copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (garage.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: AppColors.primaryRed,
                                        size: 16,
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  garage.city,
                                  style: AppFonts.labelSmall(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasCover) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            image: hasLogo
                                ? DecorationImage(
                                    image: NetworkImage(garage.logoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: !hasLogo
                              ? const Icon(
                                  Icons.car_repair_rounded,
                                  color: AppColors.accentBlue,
                                  size: 26,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
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
                                          '${garage.rating.toStringAsFixed(1)} (${garage.reviewCount})',
                                          style:
                                              AppFonts.labelSmall(
                                                color: AppColors.primaryDark,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                garage.city,
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    garage.address,
                    style: AppFonts.labelSmall(color: secondaryTextColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
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
                      Expanded(
                        child: Text(
                          garage.openHours,
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E293B),
                                  const Color(0xFF0F172A),
                                ]
                              : [
                                  const Color(0xFFF8FAFC),
                                  const Color(0xFFEEF2F6),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accentAmber.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_offer_rounded,
                              color: AppColors.accentAmber,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentAmber,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'FEATURED',
                                        style:
                                            AppFonts.labelSmall(
                                              color: Colors.black,
                                            ).copyWith(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: AppColors.accentBlue,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  featuredPackageTitle,
                                  style: AppFonts.titleSmall(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Genuine Spares & Complete Diagnostic Care',
                                  style: AppFonts.bodySmall(
                                    color: secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.infoBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Periodic Service & Wash',
                          style: AppFonts.labelSmall(
                            color: AppColors.info,
                          ).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (garage.isRoadsideAssistanceAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emergency_rounded,
                                size: 11,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Breakdown Help',
                                style:
                                    AppFonts.labelSmall(color: AppColors.error)
                                        .copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      if (garage.isDoorstepRepairAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.home_repair_service_rounded,
                                size: 11,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Doorstep Pickup',
                                style:
                                    AppFonts.labelSmall(
                                      color: AppColors.success,
                                    ).copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      _buildActionPill(
                        context: context,
                        icon: Icons.directions_rounded,
                        label: 'Directions',
                        accentColor: AppColors.info,
                        onTap: () => WhatsAppShareService.openMapDirections(
                          latitude: garage.latitude,
                          longitude: garage.longitude,
                          label: garage.name,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildActionPill(
                        context: context,
                        icon: Icons.phone_rounded,
                        label: 'Call',
                        accentColor: AppColors.primaryGreen,
                        onTap: () =>
                            WhatsAppShareService.makePhoneCall(garage.phone),
                      ),
                      const SizedBox(width: 8),
                      _buildActionPill(
                        context: context,
                        icon: Icons.chat_rounded,
                        label: 'WhatsApp',
                        accentColor: const Color(0xFF25D366),
                        onTap: () => WhatsAppShareService.openWhatsAppChat(
                          phoneNumber: garage.phone,
                          text:
                              'Hello ${garage.name}, I am inquiring about your service packages and garage services.',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildActionPill(
                        context: context,
                        icon: Icons.forum_rounded,
                        label: 'Chat',
                        accentColor: AppColors.accentBlue,
                        onTap: () => CustomerInquiryService.startInquiry(
                          context,
                          ref,
                          garage: garage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48)
                                  .withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'View Packages & Book Service',
                                style: AppFonts.labelLarge(color: Colors.white)
                                    .copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: AppFonts.labelSmall(color: accentColor)
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
