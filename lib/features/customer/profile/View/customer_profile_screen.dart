import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/customer/profile/Model/customer_profile_state.dart';
import 'package:garage_card/features/customer/profile/ViewModel/customer_profile_view_model.dart';
import 'package:go_router/go_router.dart';

import '../Widgets/customer_profile_details_card.dart';
import '../Widgets/customer_profile_header_card.dart';
import '../Widgets/customer_profile_preferences_card.dart';

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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      final ok = await ref
          .read(customerProfileViewModelProvider.notifier)
          .uploadAvatar(picked);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    final profileState = ref.watch(customerProfileViewModelProvider);
    final profileVm = ref.read(customerProfileViewModelProvider.notifier);
    final locale = ref.watch(localeProvider);
    final isMerchant = authState.activeExperience == 'merchant';

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

    final headerCard = CustomerProfileHeaderCard(
      user: user,
      isMerchant: isMerchant,
      onPickAvatar: _pickAvatar,
    );

    final detailsCard = CustomerProfileDetailsCard(
      profileState: profileState,
      profileVm: profileVm,
      user: user,
      nameCtrl: _nameCtrl,
      phoneCtrl: _phoneCtrl,
      whatsappCtrl: _whatsappCtrl,
    );

    final preferencesCard = CustomerProfilePreferencesCard(
      locale: locale,
      onLanguageChanged: (code) =>
          ref.read(localeProvider.notifier).setLocale(code),
      onNavigateToWarranties: () => context.push(RoutePaths.customerWarranties),
      onAccountSwitched: (target) {
        if (context.mounted) {
          context.go(
            target == 'merchant' ? RoutePaths.merchant : RoutePaths.customer,
          );
        }
      },
      onSignOut: () async {
        await ref.read(authViewModelProvider.notifier).signOut();
        if (context.mounted) {
          context.go(RoutePaths.auth);
        }
      },
    );

    return Scaffold(
      appBar: const AppCustomAppBar(
        title: 'Account Profile',
        subtitle: 'Personal details & mode switching',
        showAccountSwitch: true,
      ),
      body: SingleChildScrollView(
        child: AppResponsiveLayout(
          maxWidth: AppResponsiveLayout.kMaxFormWidth,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 768;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          headerCard,
                          const SizedBox(height: 18),
                          detailsCard,
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: preferencesCard),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  headerCard,
                  const SizedBox(height: 18),
                  detailsCard,
                  const SizedBox(height: 18),
                  preferencesCard,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
