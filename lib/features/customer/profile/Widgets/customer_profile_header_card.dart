import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_cached_image.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';

class CustomerProfileHeaderCard extends StatelessWidget {
  const CustomerProfileHeaderCard({
    super.key,
    required this.user,
    required this.isMerchant,
    required this.onPickAvatar,
  });

  final UserProfileModel? user;
  final bool isMerchant;
  final VoidCallback onPickAvatar;

  Widget _buildAvatarFallback(String? name) {
    final initial =
        (name != null && name.trim().isNotEmpty && name.trim() != 'User')
        ? name.trim()[0].toUpperCase()
        : 'U';
    return Center(
      child: Text(
        initial,
        style: AppFonts.displayMedium(color: Colors.white)
            .copyWith(fontWeight: FontWeight.bold, fontSize: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final displayName =
        (user?.fullName.isNotEmpty == true && user?.fullName != 'User')
        ? user!.fullName
        : 'Valued Client';

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryRed, AppColors.accentAmber],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AppCachedImage(
                    imageUrl: user?.avatarUrl,
                    width: 80,
                    height: 80,
                    isCircle: true,
                    errorWidget: _buildAvatarFallback(user?.fullName),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: onPickAvatar,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardBg, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppFonts.titleLarge(color: primaryTextColor)
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user?.email ?? '',
                    style: AppFonts.bodySmall(color: secondaryTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isMerchant
                                  ? AppColors.accentAmber
                                  : AppColors.primaryRed)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isMerchant
                          ? context.tr('merchantAccount')
                          : context.tr('customerAccount'),
                      style: AppFonts.labelSmall(
                        color: isMerchant
                            ? AppColors.accentAmber
                            : AppColors.primaryRed,
                      ).copyWith(fontWeight: FontWeight.bold),
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
}
