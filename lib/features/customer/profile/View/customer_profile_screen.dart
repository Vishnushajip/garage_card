import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/account_switcher_list_view.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/customer/profile/Model/customer_profile_state.dart';
import 'package:garage_card/features/customer/profile/ViewModel/customer_profile_view_model.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';
import 'package:go_router/go_router.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _whatsappCtrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(customerProfileViewModelProvider);
    _nameCtrl = TextEditingController(text: profile.nameInput);
    _phoneCtrl = TextEditingController(text: profile.phoneInput);
    _whatsappCtrl = TextEditingController(text: profile.whatsappInput);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    final profileState = ref.watch(customerProfileViewModelProvider);
    final profileVm = ref.read(customerProfileViewModelProvider.notifier);
    final locale = ref.watch(localeProvider);
    final isMerchant = authState.activeExperience == 'merchant';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    ref.listen<CustomerProfileState>(customerProfileViewModelProvider, (
      prev,
      next,
    ) {
      if (prev?.isEditingDetails != true && next.isEditingDetails) {
        if (_nameCtrl.text != next.nameInput) {
          _nameCtrl.text = next.nameInput;
        }
        if (_phoneCtrl.text != next.phoneInput) {
          _phoneCtrl.text = next.phoneInput;
        }
        if (_whatsappCtrl.text != next.whatsappInput) {
          _whatsappCtrl.text = next.whatsappInput;
        }
      }
    });

    return Scaffold(
      appBar: const AppCustomAppBar(
        title: 'Account Profile',
        subtitle: 'Personal details & mode switching',
        showAccountSwitch: true,
      ),
      body: SingleChildScrollView(
        child: AppResponsiveLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
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
                                colors: [
                                  AppColors.primaryRed,
                                  AppColors.accentAmber,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryRed.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child:
                                  (user?.avatarUrl != null &&
                                      user!.avatarUrl!.isNotEmpty)
                                  ? Image.network(
                                      user.avatarUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          _buildAvatarFallback(user.fullName),
                                    )
                                  : _buildAvatarFallback(user?.fullName),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 800,
                                  maxHeight: 800,
                                  imageQuality: 85,
                                );
                                if (picked != null) {
                                  final ok = await profileVm.uploadAvatar(
                                    picked,
                                  );
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Avatar updated successfully!',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                }
                              },
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
                              user?.fullName.isNotEmpty == true &&
                                      user?.fullName != 'User'
                                  ? user!.fullName
                                  : 'Valued Client',
                              style: AppFonts.titleLarge(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user?.email ?? '',
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isMerchant
                                    ? AppColors.accentAmber.withValues(
                                        alpha: 0.12,
                                      )
                                    : AppColors.primaryRed.withValues(
                                        alpha: 0.12,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isMerchant
                                    ? 'Merchant Account'
                                    : 'Customer Account',
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
              ),
              const SizedBox(height: 18),
              _buildProfileDetailsCard(
                context: context,
                profileState: profileState,
                profileVm: profileVm,
                user: user,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
              const SizedBox(height: 18),
              Card(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language Preference',
                        style: AppFonts.titleMedium(color: primaryTextColor)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select your preferred display language',
                        style: AppFonts.labelSmall(color: secondaryTextColor),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _LanguagePill(
                              code: 'en',
                              title: 'English',
                              subtitle: 'Default',
                              isSelected: locale.languageCode == 'en',
                              isDark: isDark,
                              onTap: () => ref
                                  .read(localeProvider.notifier)
                                  .setLocale('en'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LanguagePill(
                              code: 'ml',
                              title: 'മലയാളം',
                              subtitle: 'Malayalam',
                              isSelected: locale.languageCode == 'ml',
                              isDark: isDark,
                              onTap: () => ref
                                  .read(localeProvider.notifier)
                                  .setLocale('ml'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Warranty Vault',
                      style: AppFonts.titleMedium(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'View replacement parts coverage & guarantee certificates',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondaryLight,
                    ),
                    onTap: () => context.push(RoutePaths.customerWarranties),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: AppColors.primaryRed,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Switching',
                                  style: AppFonts.titleMedium(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Switch between Customer & Merchant workspaces',
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AccountSwitcherListView(
                        onSwitched: (target) {
                          if (context.mounted) {
                            context.go(
                              target == 'merchant'
                                  ? RoutePaths.merchant
                                  : RoutePaths.customer,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WeFix Garage',
                          style: AppFonts.labelSmall(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Version 1.0.0 (Build 2026.1)',
                          style: AppFonts.labelSmall(color: secondaryTextColor)
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () async {
                        await ref
                            .read(authViewModelProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          context.go(RoutePaths.auth);
                        }
                      },
                      icon: const Icon(
                        Icons.power_settings_new_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      label: Text(
                        'Sign Out',
                        style: AppFonts.labelSmall(color: AppColors.error)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildProfileDetailsCard({
    required BuildContext context,
    required CustomerProfileState profileState,
    required CustomerProfileViewModel profileVm,
    required UserProfileModel? user,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
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
                                ? 'Edit Profile Details'
                                : 'Complete Profile Details',
                            style: AppFonts.titleMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cancel',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: profileVm.cancelEditingDetails,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameCtrl,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                onChanged: profileVm.setName,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Phone Number (for Calling & Login)',
                hint: '+91 98765 43210',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                onChanged: profileVm.setPhone,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'WhatsApp Number (for Repair & Service Updates)',
                      style: AppFonts.labelLarge(color: primaryTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _whatsappCtrl.text = _phoneCtrl.text;
                      profileVm.setWhatsApp(_phoneCtrl.text);
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
                            'Same as Phone',
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
                helperText: 'Vehicle status notifications & estimates will be sent to this WhatsApp number',
                controller: _whatsappCtrl,
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
                      label: 'Cancel',
                      variant: AppButtonVariant.outline,
                      onPressed: profileVm.cancelEditingDetails,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Save Profile Details',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const SizedBox(width: 12),
                      Text(
                        'Profile Incomplete',
                        style: AppFonts.titleMedium(color: primaryTextColor)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(profileState.completionPercentage * 100).toInt()}% Complete',
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
                'Complete your personal details to receive instant repair updates, digital estimates, and WhatsApp service notifications.',
                style: AppFonts.bodySmall(color: secondaryTextColor),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Complete Profile Now',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(width: 12),
                    Text(
                      'Profile Details',
                      style: AppFonts.titleMedium(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '100% Complete',
                    style: AppFonts.labelSmall(color: AppColors.success)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileDetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Full Name',
              value:
                  (user?.fullName.isNotEmpty == true &&
                      user?.fullName != 'User')
                  ? user!.fullName
                  : 'Not provided',
              primaryColor: primaryTextColor,
              secondaryColor: secondaryTextColor,
            ),
            const Divider(height: 18),
            _ProfileDetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: user?.phoneNumber.isNotEmpty == true
                  ? user!.phoneNumber
                  : 'Not provided',
              primaryColor: primaryTextColor,
              secondaryColor: secondaryTextColor,
            ),
            const Divider(height: 18),
            _ProfileDetailRow(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'WhatsApp Number',
              value: user?.whatsappNumber.isNotEmpty == true
                  ? user!.whatsappNumber
                  : 'Not provided',
              primaryColor: primaryTextColor,
              secondaryColor: secondaryTextColor,
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Edit Profile Details',
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

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withValues(alpha: 0.12)
              : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryRed
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style:
                  AppFonts.titleSmall(
                    color: isSelected
                        ? AppColors.primaryRed
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ).copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppFonts.labelSmall(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
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
