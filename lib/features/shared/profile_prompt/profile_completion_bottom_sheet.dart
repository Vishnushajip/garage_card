import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/customer/profile/ViewModel/customer_profile_view_model.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';

import 'profile_completion_prompt_service.dart';

class ProfileCompletionBottomSheet extends ConsumerStatefulWidget {
  const ProfileCompletionBottomSheet({super.key, required this.userProfile});

  final UserProfileModel userProfile;

  @override
  ConsumerState<ProfileCompletionBottomSheet> createState() =>
      _ProfileCompletionBottomSheetState();
}

class _ProfileCompletionBottomSheetState
    extends ConsumerState<ProfileCompletionBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;

  @override
  void initState() {
    super.initState();
    final profile = widget.userProfile;
    final initialName = profile.fullName == 'User' ? '' : profile.fullName;
    _nameController = TextEditingController(text: initialName);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _whatsappController = TextEditingController(text: profile.whatsappNumber);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(customerProfileViewModelProvider.notifier);
      vm.setName(initialName);
      vm.setPhone(profile.phoneNumber);
      vm.setWhatsApp(profile.whatsappNumber);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProfileViewModelProvider);
    final vm = ref.read(customerProfileViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final hasName = _nameController.text.trim().isNotEmpty;
    final hasPhone = _phoneController.text.trim().isNotEmpty;
    final hasWhatsApp = _whatsappController.text.trim().isNotEmpty;
    var completedCount = 1;
    if (hasName) completedCount++;
    if (hasPhone) completedCount++;
    if (hasWhatsApp) completedCount++;
    final progress = completedCount / 4.0;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentBlue, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_pin_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Your Profile',
                        style: AppFonts.headlineSmall(
                          color: primaryTextColor,
                        ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Unlock WhatsApp alerts & instant approvals',
                        style: AppFonts.bodySmall(color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: progress >= 1.0
                        ? AppColors.successBg
                        : AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}% Done',
                    style: AppFonts.labelSmall(
                      color: progress >= 1.0
                          ? AppColors.success
                          : AppColors.accentBlue,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppColors.success : AppColors.accentBlue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  _ChecklistRow(
                    label: widget.userProfile.email.isNotEmpty
                        ? widget.userProfile.email
                        : 'Email Address',
                    isComplete: widget.userProfile.email.isNotEmpty,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _ChecklistRow(
                    label: 'Full Name',
                    isComplete: hasName,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _ChecklistRow(
                    label: 'Phone Number (Calls & Login)',
                    isComplete: hasPhone,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _ChecklistRow(
                    label: 'WhatsApp Number (Repair Updates)',
                    isComplete: hasWhatsApp,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Full Name',
              hint: 'e.g. John Doe',
              controller: _nameController,
              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
              onChanged: (val) {
                vm.setName(val);
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Phone Number (Calling)',
              hint: 'e.g. +91 98765 43210',
              controller: _phoneController,
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              keyboardType: TextInputType.phone,
              onChanged: (val) {
                vm.setPhone(val);
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'WhatsApp Number',
                    style: AppFonts.labelLarge(color: primaryTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    _whatsappController.text = _phoneController.text;
                    vm.setWhatsApp(_phoneController.text);
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          size: 12,
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
              hint: 'e.g. +91 98765 43210',
              helperText: 'Repair status and estimates will be sent to this WhatsApp number',
              controller: _whatsappController,
              prefixIcon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: AppColors.success,
              ),
              keyboardType: TextInputType.phone,
              onChanged: (val) {
                vm.setWhatsApp(val);
                setState(() {});
              },
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.errorMessage!,
                  style: AppFonts.bodySmall(color: AppColors.error),
                ),
              ),
            ],
            const SizedBox(height: 22),
            AppButton(
              label: 'Save & Complete Profile',
              isFullWidth: true,
              isLoading: state.isSaving,
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final success = await vm.saveProfile();
                if (success && mounted) {
                  final promptService = ref.read(
                    profileCompletionPromptServiceProvider,
                  );
                  await promptService.markProfileCompleted(
                    widget.userProfile.uid,
                  );
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Profile completed successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Remind Me Tomorrow',
                style: AppFonts.bodyMedium(color: secondaryTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.isComplete,
    required this.isDark,
  });

  final String label;
  final bool isComplete;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Row(
      children: [
        Icon(
          isComplete
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked,
          color: isComplete ? AppColors.success : mutedColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppFonts.bodySmall(
              color: isComplete
                  ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                  : mutedColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
