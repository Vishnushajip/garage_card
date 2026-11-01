import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';

import '../Model/garage_profile_state.dart';
import '../ViewModel/garage_profile_view_model.dart';

class GarageProfileHeaderCard extends StatelessWidget {
  const GarageProfileHeaderCard({
    super.key,
    required this.state,
    required this.vm,
    required this.displayName,
    required this.displayEmail,
    required this.displayPhone,
    required this.completionPct,
  });

  final GarageProfileState state;
  final GarageProfileViewModel vm;
  final String displayName;
  final String displayEmail;
  final String displayPhone;
  final double completionPct;

  Widget _buildLogoFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentBlue, AppColors.primaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppFonts.displayMedium(color: Colors.white)
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCoverFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.storefront_rounded, size: 40, color: Colors.white24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Card(
      color: cardBg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2.8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                state.garage?.coverImageUrl != null &&
                        state.garage!.coverImageUrl!.isNotEmpty
                    ? Image.network(
                        state.garage!.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            _buildCoverFallback(),
                      )
                    : _buildCoverFallback(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_camera_rounded, size: 14),
                    label: Text(
                      state.garage?.coverImageUrl != null
                          ? 'Change Banner'
                          : 'Upload Banner',
                      style: AppFonts.labelSmall(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (picked != null && context.mounted) {
                        final ok = await vm.uploadGarageCover(picked);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Garage banner updated successfully!',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        state.garage?.logoUrl != null &&
                                state.garage!.logoUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  state.garage!.logoUrl!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      _buildLogoFallback(displayName),
                                ),
                              )
                            : _buildLogoFallback(displayName),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Material(
                            color: AppColors.accentBlue,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 85,
                                );
                                if (picked != null && context.mounted) {
                                  final ok = await vm.uploadGarageLogo(picked);
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Garage logo updated successfully!',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppFonts.titleLarge(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayEmail,
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (displayPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              displayPhone,
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const AppStatusBadge(
                                status: 'approved',
                                customLabel: 'VERIFIED GARAGE',
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.infoBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'PLAN: PRO TIER',
                                  style: AppFonts.labelSmall(
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Completion',
                      style: AppFonts.labelMedium(color: secondaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(completionPct * 100).toInt()}% Complete',
                      style: AppFonts.labelMedium(
                        color: completionPct == 1.0
                            ? AppColors.success
                            : AppColors.accentAmber,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completionPct,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completionPct == 1.0
                          ? AppColors.success
                          : AppColors.accentAmber,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Last Active: Today, Active Session',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Online',
                          style: AppFonts.labelSmall(color: AppColors.success)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
