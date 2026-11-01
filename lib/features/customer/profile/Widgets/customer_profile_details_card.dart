import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/customer/profile/Model/customer_profile_state.dart';
import 'package:garage_card/features/customer/profile/ViewModel/customer_profile_view_model.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';

class CustomerProfileDetailsCard extends StatelessWidget {
  const CustomerProfileDetailsCard({
    super.key,
    required this.profileState,
    required this.profileVm,
    required this.user,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.whatsappCtrl,
  });

  final CustomerProfileState profileState;
  final CustomerProfileViewModel profileVm;
  final UserProfileModel? user;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController whatsappCtrl;

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

    if (profileState.isEditingDetails) {
      return Card(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.primaryRed.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: AppColors.primaryRed,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profileState.isProfileComplete
                                ? context.tr('editProfileDetails')
                                : context.tr('completeProfileDetails'),
                            style: AppFonts.titleMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('cancel'),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: profileVm.cancelEditingDetails,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: context.tr('fullName'),
                hint: context.tr('enterFullName'),
                controller: nameCtrl,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                onChanged: profileVm.setName,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: context.tr('phoneNumberForCalling'),
                hint: '+91 98765 43210',
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                onChanged: profileVm.setPhone,
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text(
                    context.tr('whatsappNumber'),
                    style: AppFonts.labelLarge(color: primaryTextColor),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      whatsappCtrl.text = phoneCtrl.text;
                      profileVm.setWhatsApp(phoneCtrl.text);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('sameAsPhone'),
                            style: AppFonts.labelSmall(
                              color: AppColors.accentBlue,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AppTextField(
                hint: '+91 98765 43210',
                helperText: context.tr('whatsappHelperText'),
                controller: whatsappCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: AppColors.success,
                ),
                onChanged: profileVm.setWhatsApp,
              ),
              if (profileState.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  profileState.errorMessage!,
                  style: AppFonts.labelSmall(color: AppColors.error),
                ),
              ],
              if (profileState.successMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profileState.successMessage!,
                      style: AppFonts.labelSmall(color: AppColors.success),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: context.tr('cancel'),
                      variant: AppButtonVariant.outline,
                      onPressed: profileVm.cancelEditingDetails,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: context.tr('saveProfileDetails'),
                      isLoading: profileState.isSaving,
                      onPressed: profileVm.saveProfile,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (!profileState.isProfileComplete) {
      return Card(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.accentAmber.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.contact_page_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('profileIncomplete'),
                      style: AppFonts.titleMedium(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(profileState.completionPercentage * 100).toInt()}% ${context.tr('complete')}',
                      style: AppFonts.labelSmall(color: AppColors.warning)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: profileState.completionPercentage,
                  backgroundColor: isDark
                      ? AppColors.borderDark.withValues(alpha: 0.3)
                      : AppColors.borderLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('completePersonalDetailsDesc'),
                style: AppFonts.bodySmall(color: secondaryTextColor),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: context.tr('completeProfileNow'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                isFullWidth: true,
                onPressed: profileVm.startEditingDetails,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr('profileDetails'),
                    style: AppFonts.titleMedium(color: primaryTextColor)
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '100% ${context.tr('complete')}',
                    style: AppFonts.labelSmall(color: AppColors.success)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileDetailRow(
              icon: Icons.person_outline_rounded,
              label: context.tr('fullName'),
              value:
                  (user?.fullName.isNotEmpty == true &&
                      user?.fullName != 'User')
                  ? user!.fullName
                  : context.tr('notProvided'),
              primaryColor: primaryTextColor,
              secondaryColor: secondaryTextColor,
            ),
            const Divider(height: 18),
            _ProfileDetailRow(
              icon: Icons.phone_outlined,
              label: context.tr('phoneNumber'),
              value: user?.phoneNumber.isNotEmpty == true
                  ? user!.phoneNumber
                  : context.tr('notProvided'),
              primaryColor: primaryTextColor,
              secondaryColor: secondaryTextColor,
            ),
            const Divider(height: 18),
            _ProfileDetailRow(
              icon: Icons.chat_bubble_outline_rounded,
              label: context.tr('whatsappNumber'),
              value: user?.whatsappNumber.isNotEmpty == true
                  ? user!.whatsappNumber
                  : context.tr('notProvided'),
              primaryColor: primaryTextColor,
              secondaryColor: secondaryTextColor,
            ),
            const SizedBox(height: 18),
            AppButton(
              label: context.tr('editProfileDetails'),
              variant: AppButtonVariant.outline,
              icon: const Icon(Icons.edit_outlined, size: 16),
              isFullWidth: true,
              onPressed: profileVm.startEditingDetails,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: secondaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppFonts.labelSmall(color: secondaryColor)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppFonts.bodyMedium(color: primaryColor)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
