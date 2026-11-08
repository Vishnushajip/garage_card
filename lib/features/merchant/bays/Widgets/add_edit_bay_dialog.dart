import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';

class AddEditBayDialog extends StatefulWidget {
  const AddEditBayDialog({super.key, required this.onSave});

  final void Function(String name, String type) onSave;

  static Future<void> show(
    BuildContext context, {
    required void Function(String name, String type) onSave,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AddEditBayDialog(onSave: onSave),
    );
  }

  @override
  State<AddEditBayDialog> createState() => _AddEditBayDialogState();
}

class _AddEditBayDialogState extends State<AddEditBayDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = 'twoWheeler';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.onSave(name, _selectedType);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return AlertDialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.garage_rounded, color: AppColors.accentBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr('addBay'),
              style: AppFonts.titleMedium(color: primaryTextColor),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: context.tr('bayName'),
            hint: 'e.g. Ramp 4 (Hydraulic)',
            controller: _nameController,
            prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded),
          ),
          const SizedBox(height: 12),
          AppDropdown<String>(
            label: context.tr('bayType'),
            value: _selectedType,
            items: const [
              AppDropdownItem(
                value: 'twoWheeler',
                title: 'Two Wheeler Lift',
                icon: Icon(Icons.two_wheeler_rounded),
              ),
              AppDropdownItem(
                value: 'fourWheeler',
                title: 'Four Wheeler Ramp',
                icon: Icon(Icons.directions_car_rounded),
              ),
              AppDropdownItem(
                value: 'detailing',
                title: 'Washing & Detailing',
                icon: Icon(Icons.local_car_wash_rounded),
              ),
              AppDropdownItem(
                value: 'quickService',
                title: 'Quick Service Pit',
                icon: Icon(Icons.speed_rounded),
              ),
              AppDropdownItem(
                value: 'general',
                title: 'General Repair Bay',
                icon: Icon(Icons.build_rounded),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedType = val);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        SizedBox(
          width: 100,
          child: AppButton(
            label: context.tr('save'),
            onPressed: _submit,
            height: 38,
          ),
        ),
      ],
    );
  }
}
