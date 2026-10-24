import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';

class AuthRoleSelector extends StatelessWidget {
  const AuthRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    this.enabled = true,
  });

  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppDropdown<String>(
      label: 'Intended Experience',
      hint: 'Select your role',
      value: selectedRole,
      enabled: enabled,
      onChanged: (val) {
        if (val != null) onRoleChanged(val);
      },
      items: const [
        AppDropdownItem<String>(
          value: 'customer',
          title: 'Customer Experience',
          subtitle: 'Track vehicles, view estimates & invoices',
          icon: Icon(Icons.person_rounded, color: AppColors.accentBlue),
        ),
        AppDropdownItem<String>(
          value: 'merchant',
          title: 'Merchant / Garage Owner',
          subtitle: 'Manage repairs, customers & billing',
          icon: Icon(Icons.storefront_rounded, color: AppColors.accentAmber),
        ),
      ],
    );
  }
}
