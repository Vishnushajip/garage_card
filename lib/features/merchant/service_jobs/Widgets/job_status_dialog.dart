import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';

class JobStatusDialog extends StatefulWidget {
  const JobStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onUpdateStatus,
  });

  final String currentStatus;
  final Future<bool> Function(String newStatus, String notes) onUpdateStatus;

  @override
  State<JobStatusDialog> createState() => _JobStatusDialogState();
}

class _JobStatusDialogState extends State<JobStatusDialog> {
  late String _selectedStatus;
  final TextEditingController _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _isLoading = true);
    final success = await widget.onUpdateStatus(
      _selectedStatus,
      _notesCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return AlertDialog(
      title: Text(
        'Update Repair Status',
        style: AppFonts.titleLarge(color: primaryTextColor),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdown<String>(
              label: 'New Status',
              value: _selectedStatus,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedStatus = val);
                }
              },
              items: const [
                AppDropdownItem(
                  value: 'received',
                  title: 'Received',
                  subtitle: 'Vehicle parked at workshop',
                ),
                AppDropdownItem(
                  value: 'inspectionPending',
                  title: 'Inspection Pending',
                  subtitle: 'Awaiting mechanic inspection',
                ),
                AppDropdownItem(
                  value: 'estimatePending',
                  title: 'Estimate Pending',
                  subtitle: 'Parts pricing & quote in progress',
                ),
                AppDropdownItem(
                  value: 'inProgress',
                  title: 'In Progress',
                  subtitle: 'Mechanics working on vehicle',
                ),
                AppDropdownItem(
                  value: 'readyForCollection',
                  title: 'Ready for Collection',
                  subtitle: 'Work completed, car washed',
                ),
                AppDropdownItem(
                  value: 'completed',
                  title: 'Completed & Delivered',
                  subtitle: 'Customer picked up vehicle',
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _notesCtrl,
              label: 'Customer Update Note',
              hint: 'e.g. Brake rotors turned, new pads installed. Testing car now.',
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: 'Save & Notify Customer',
          onPressed: _submit,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
